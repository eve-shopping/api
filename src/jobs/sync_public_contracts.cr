TOKEN = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkpXVC1TaWduYXR1cmUtS2V5IiwidHlwIjoiSldUIn0.eyJzY3AiOiJlc2ktdW5pdmVyc2UucmVhZF9zdHJ1Y3R1cmVzLnYxIiwianRpIjoiYjZmMzgwYTktOTQ1Ny00ZGM3LWFkZWQtOThjYzE2YmRkMWQ3Iiwia2lkIjoiSldULVNpZ25hdHVyZS1LZXkiLCJzdWIiOiJDSEFSQUNURVI6RVZFOjIwNDc5MTgyOTEiLCJhenAiOiI2NzQ4MDI2Y2QzMjQ0ZjE2ODU2YzEzNDAyMjg1MGM5OCIsIm5hbWUiOiJCbGFja3Ntb2tlMTYiLCJvd25lciI6IlJIbkFBcjZPbklTSWx0TVpzSmdTSnhwbm5Gaz0iLCJleHAiOjE1OTkzMjc3MTksImlzcyI6ImxvZ2luLmV2ZW9ubGluZS5jb20ifQ.cJir04Sovj-csCVlxm-k_zPk7dYUj6mT6dJJDxVo3sSg-tRNyzwboVuowkkb6BEoLS8u6o4Dgyir9feVw9RHhZ_BETKx5rhARNzWnzxSWiyTbFtPoQYTroVpdJHbxXDcv64s62nvH-oZL6DZjmbSfJKUei3t9UflwZwpQi4FuWWtnRKtLgij2F_U3G9b0WJm9kdZxeS1Md-_JFQI4xvhRt7UuZGvz2bMYLBy_KOZzDWZe3y9qBy1mTSPxuQFU9EAtrm1fkkj0ZgZRyqy8rpjDCMarApI5foeOa0Y-AdX9ar5VLx-yVoYJfuWWxZbi7NQB5xtNKMbA76m_naqsV_AiA"

class SyncPublicContractsJob < Mosquito::PeriodicJob
  run_every 30.minutes

  @resolved_character_ids = Set(Int32).new
  @corporation_alliance_map = Hash(Int32, Int32?).new
  @structure_corporation_map = Hash(Int64, Int32).new

  def perform
    regions = Channel(Bool).new

    EveShoppingAPI::Models::SDE::Region.all.first(1).each do |region|
      spawn do
        contract_data = Channel(Bool).new

        Log.debug { "Resolving region: #{region.id}" }

        public_contracts = ASR.serializer.deserialize Array(EveShoppingAPI::Models::Contract), HTTP::Client.get("https://esi.evetech.net/v1/contracts/public/#{region.id}").body, :json

        location_ids = Set(Int64).new

        public_contracts.first(2).each do |contract|
          # Fix some data before processing it
          contract.availability = :public
          contract.status = :outstanding
          contract.origin = :public

          self.resolve_issuer_affiliation contract

          # Skip trying to save contracts whose locations could not be resolved
          # E.x. Not public
          unless self.resolve_start_location_affiliation contract
            Log.debug { "Skipping contract #{contract.id}" }
            next
          end

          EveShoppingAPI::Models::Contract.adapter.database.transaction do
            contract.save!
          end

          pp contract
        end

        regions.send true
      end
    end

    1.times do
      regions.receive
    end

    # self.store_affiliation_data
  end

  # Resolve alliance of the issuer
  # TODO: Remove this once https://github.com/esi/esi-issues/issues/1212 is resolved.
  private def resolve_issuer_affiliation(contract : EveShoppingAPI::Models::Contract) : Nil
    character_id = contract.issuer_id

    if @resolved_character_ids.add? character_id
      Log.debug { "Caching character #{character_id}" }

      unless EveShoppingAPI::Models::Character.exists? character_id
        Log.debug { "Saving new character #{character_id}" }

        response = HTTP::Client.get("https://esi.evetech.net/v4/characters/#{character_id}/")

        # TODO: Handle retries
        unless response.success?
          Log.warn { "Unable to resolve character #{character_id}" }
          return
        end

        character = EveShoppingAPI::Models::Character.from_json response.body
        character.id = character_id
        character.save!
      end
    else
      Log.debug { "Reading character from cache #{character_id}" }
    end

    self.resolve_corporation contract.issuer_corporation_id

    contract.issuer_alliance_id = @corporation_alliance_map[contract.issuer_corporation_id]
  end

  private def resolve_start_location_affiliation(contract : EveShoppingAPI::Models::Contract) : Bool
    # No need to resolve affiliation data for stations as they are static data.
    return true if contract.is_start_station? && !contract.type.courier?
    return true if contract.is_start_station? && contract.is_end_station? && contract.type.courier?

    start_location_id = contract.start_location_id

    if @structure_corporation_map.has_key? start_location_id
      Log.debug { "Reading structure from cache #{start_location_id}" }
      return true
    end

    Log.debug { "Caching structure #{start_location_id}" }

    response = HTTP::Client.get "https://esi.evetech.net/v2/universe/structures/#{start_location_id}/", headers: HTTP::Headers{"authorization" => "Bearer #{TOKEN}"}

    # TODO: Handle retries
    unless response.success?
      Log.warn { "Unable to resolve structure #{start_location_id}: #{response.status_code}" }
      return false
    end

    structure = EveShoppingAPI::Models::Structure.from_json response.body
    structure.id = start_location_id

    unless EveShoppingAPI::Models::Structure.exists? start_location_id
      Log.debug { "Saving new start location #{start_location_id}" }
      structure.save!
    end

    corporation_id = structure.owner_id.not_nil!

    @structure_corporation_map[start_location_id] = corporation_id
    self.resolve_corporation corporation_id

    true
  end

  # private def resolve_station

  private def resolve_corporation(corporation_id : Int32) : Nil
    if @corporation_alliance_map.has_key? corporation_id
      Log.debug { "Reading corporation from cache #{corporation_id}" }
      return
    end

    Log.debug { "Caching corporation #{corporation_id}" }

    response = HTTP::Client.get("https://esi.evetech.net/v4/corporations/#{corporation_id}/")

    # TODO: Handle retries
    unless response.success?
      Log.warn { "Unable to resolve corporation #{corporation_id}" }
      return
    end

    corporation = EveShoppingAPI::Models::Corporation.from_json response.body
    corporation.id = corporation_id

    unless EveShoppingAPI::Models::Corporation.exists? corporation_id
      Log.debug { "Saving new corporation #{corporation_id}" }
      corporation.save!
    end

    corporation.alliance_id.try do |alliance_id|
      unless EveShoppingAPI::Models::Alliance.exists? alliance_id
        response = HTTP::Client.get("https://esi.evetech.net/v3/alliances/#{alliance_id}/")

        # TODO: Handle retries
        unless response.success?
          Log.warn { "Unable to resolve alliance #{alliance_id}" }
          return
        end

        Log.debug { "Saving new alliance #{alliance_id}" }

        alliance = EveShoppingAPI::Models::Alliance.from_json response.body
        alliance.id = alliance_id
        alliance.save!
      end
    end

    @corporation_alliance_map[corporation_id] = corporation.alliance_id
  end
end

# location_ids = data.map(&.["start_location_id"].as_i64).uniq

# location_ids.each do |location_id|
#   spawn do
#     if location_id > 1_000_000_000_000
#       structure_count += 1
#       key = "structures"
#     else
#       station_count += 1
#       key = "stations"
#     end

#     Log.debug { "Resolving #{key}: #{location_id}" }

#     structure_data = HTTP::Client.get "https://esi.evetech.net/latest/universe/#{key}/#{location_id}/", headers: headers

#     if structure_data.status.ok?
#       resolved_structures[location_id] = JSON.parse(structure_data.body)["name"].as_s
#     elsif structure_data.status.forbidden?
#       resolved_structures[location_id] = "PRIVATE"
#       private_structures += 1
#     elsif structure_data.status.unauthorized?
#       abort "TOKEN EXPIRED"
#     else
#       resolved_structures[location_id] = "ERROR"
#     end

#     structures.send true
#   end
# end

# location_ids.size.times do
#   structures.receive
# end
