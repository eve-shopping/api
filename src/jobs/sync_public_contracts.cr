require "concurrent/semaphore"

class ESIClient
  private ERROR_BACKOFF_LIMIT = 25

  @remaining_errors = 100
  @error_refresh = 60

  def request(path : String, headers : HTTP::Headers = HTTP::Headers.new, & : HTTP::Client::Response ->)
    self.with_client do |client|
      client.get(path, headers) do |response|
        data = unless response.success?
          response_body = response.body_io.gets_to_end

          Log.notice { "Request failed #{path}: #{response_body}" }

          if response.status.forbidden? && response_body.includes? "Forbidden"
            structure_id = path.match(/\/structures\/(\d+)\//).not_nil![1].to_i64

            EveShoppingAPI::Models::PrivateStructure.create(id: structure_id)
          end

          # TODO: Retry these
          raise Exception.new response_body if response.status.server_error?

          nil
        else
          yield response
        end

        @remaining_errors = response.headers["x-esi-error-limit-remain"].to_i
        @error_refresh = response.headers["x-esi-error-limit-reset"].to_i + 1

        data
      end
    end
  end

  def request_all(path : String, type : T.class) : Array(T) forall T
    self.with_client do |client|
      response = client.get(path)

      unless response.success?
        Log.notice { "Request failed #{path}: #{response.body}" }
        raise Exception.new response.body
      end

      data = ASR.serializer.deserialize Array(T), response.body, :json
      pages = response.headers["x-pages"]?.try &.to_i

      Log.info { "#{path} has #{pages} page(s)" }

      return data if pages.nil? || pages == 1

      data_channel = Channel(Array(T)).new

      (2..pages).each do |page|
        spawn do
          self.with_client do |inner_client|
            Log.debug { "Fetching page #{page} of #{path}" }

            path_with_page = "#{path}?page=#{page}"

            inner_client.get(path_with_page) do |response|
              unless response.success?
                Log.notice { "Request failed #{path_with_page}: #{response.body}" }
                raise Exception.new response.body_io.gets_to_end
              end

              data_channel.send ASR.serializer.deserialize(Array(T), response.body_io, :json)
            end
          end
        end
      end

      (pages - 1).times do
        data.concat data_channel.receive
      end

      data
    end
  end

  private def check_errors : Nil
    if @remaining_errors <= ERROR_BACKOFF_LIMIT
      Log.warn { "Reached error limit, sleeping #{@error_refresh}" }
      sleep @error_refresh
    end
  end

  private def with_client(& : HTTP::Client ->)
    self.check_errors

    yield HTTP::Client.new "esi.evetech.net", tls: true
  end
end

class SyncPublicContractsJob < Mosquito::PeriodicJob
  run_every 30.minutes

  @resolved_character_ids = Set(Int32).new
  @corporation_alliance_map = Hash(Int32, Int32?).new
  @structure_corporation_map = Hash(Int64, Int32).new

  @private_structure_ids = [] of Int64

  @esi_client = ESIClient.new

  def perform
    regions_channel = Channel(Bool).new
    regions = EveShoppingAPI::Models::SDE::Region.all

    outstanding_contract_ids = EveShoppingAPI::Models::Contract.all("WHERE status = 'outstanding'").map &.id
    active_contract_ids = Array(Int32).new
    @private_structure_ids = EveShoppingAPI::Models::PrivateStructure.all.map &.id.not_nil!

    sem = Concurrent::Semaphore.new 20

    regions.each do |region|
      spawn do
        sem.acquire do
          contract_data = Channel(Bool).new

          Log.info { "Processing contracts in region #{region.id}" }

          begin
            public_contracts = @esi_client.request_all("/v1/contracts/public/#{region.id}/", EveShoppingAPI::Models::Contract)
          rescue ex : Exception
            Log.warn { "Skipping region #{region.id} due to exception: #{ex.message}" }
            regions_channel.send false
            next
          end

          public_contracts.not_nil!.each do |contract|
            active_contract_ids << contract.id

            # Skip already saved contracts
            next if outstanding_contract_ids.includes? contract.id

            # Skip private structures
            next if @private_structure_ids.includes?(contract.start_location_id)

            if (end_location_id = contract.end_location_id)
              next if @private_structure_ids.includes?(end_location_id)
            end

            Log.info { "Processing new contract #{contract.id} in region #{region.id}" }

            # Fix some data before processing it
            contract.availability = :public
            contract.status = :outstanding
            contract.origin = :public

            self.resolve_issuer_affiliation contract

            if !contract.is_start_station?
              # Skip trying to save contracts whose locations could not be resolved
              # E.x. Not public
              unless self.resolve_structure_affiliation contract.start_location_id
                Log.info { "Skipping invalid contract #{contract.id} in region #{region.id}: private start location" }
                next
              end
            end

            if !contract.is_end_station? && (end_location_id = contract.end_location_id)
              unless self.resolve_structure_affiliation end_location_id
                Log.info { "Skipping invalid contract #{contract.id} in region #{region.id}: private end location" }
                next
              end
            end

            EveShoppingAPI::Models::Contract.adapter.database.transaction do
              contract.save!

              unless contract.is_start_station?
                structure_affiliation = EveShoppingAPI::Models::ContractStructureAffiliation.new
                structure_affiliation.contract_id = contract.id
                structure_affiliation.origin = :start
                structure_affiliation.structure_id = contract.start_location_id
                structure_affiliation.corporation_id = @structure_corporation_map[contract.start_location_id]
                structure_affiliation.alliance_id = @corporation_alliance_map[structure_affiliation.corporation_id]
                structure_affiliation.save!
              end

              if !contract.is_end_station? && (end_location_id = contract.end_location_id)
                structure_affiliation = EveShoppingAPI::Models::ContractStructureAffiliation.new
                structure_affiliation.contract_id = contract.id
                structure_affiliation.origin = :end
                structure_affiliation.structure_id = end_location_id
                structure_affiliation.corporation_id = @structure_corporation_map[end_location_id]
                structure_affiliation.alliance_id = @corporation_alliance_map[structure_affiliation.corporation_id]
                structure_affiliation.save!
              end
            end
          rescue ex : Exception
            Log.warn { "Skipping contract #{contract.id} in region #{region.id} due to exception: #{ex.message}" }
            next
          end

          regions_channel.send true
        end
      end
    end

    regions.size.times do
      regions_channel.receive
    end

    missing_ids = outstanding_contract_ids - active_contract_ids

    Log.info { "Invalidating #{missing_ids.size} contract(s)" }

    # Set missing contracts status to unknown since the actual outcome cannot be determined.
    EveShoppingAPI::Models::Contract.exec %(UPDATE "contracts" SET "status" = 'unknown' WHERE "id" IN (#{missing_ids.join(",")});) unless missing_ids.empty?
  end

  # Resolve alliance of the issuer
  # TODO: Remove this once https://github.com/esi/esi-issues/issues/1212 is resolved.
  private def resolve_issuer_affiliation(contract : EveShoppingAPI::Models::Contract) : Nil
    character_id = contract.issuer_id

    if @resolved_character_ids.add? character_id
      Log.debug { "Caching character #{character_id}" }

      unless EveShoppingAPI::Models::Character.exists? character_id
        Log.info { "Saving new character #{character_id}" }

        return unless character = @esi_client.request "/v4/characters/#{character_id}/" do |response|
                        EveShoppingAPI::Models::Character.from_json response.body_io
                      end

        character.id = character_id
        character.save!
      end
    else
      Log.debug { "Reading character from cache #{character_id}" }
    end

    self.resolve_corporation contract.issuer_corporation_id

    contract.issuer_alliance_id = @corporation_alliance_map[contract.issuer_corporation_id]
  end

  private def resolve_structure_affiliation(structure_id : Int64) : Bool
    if @structure_corporation_map.has_key? structure_id
      Log.debug { "Reading structure from cache #{structure_id}" }
      return true
    end

    Log.debug { "Caching structure #{structure_id}" }

    structure = @esi_client.request "/v2/universe/structures/#{structure_id}/", HTTP::Headers{"authorization" => "Bearer #{EveShoppingAPI::ServiceAccount.access_token}"} do |response|
      EveShoppingAPI::Models::Structure.from_json response.body_io
    end

    unless structure
      @private_structure_ids << structure_id
      return false
    end

    structure.id = structure_id

    unless EveShoppingAPI::Models::Structure.exists? structure_id
      Log.info { "Saving new structure #{structure_id}" }
      structure.save!
    end

    corporation_id = structure.owner_id.not_nil!

    @structure_corporation_map[structure_id] = corporation_id
    self.resolve_corporation corporation_id

    true
  end

  private def resolve_corporation(corporation_id : Int32) : Nil
    if @corporation_alliance_map.has_key? corporation_id
      Log.debug { "Reading corporation from cache #{corporation_id}" }
      return
    end

    Log.debug { "Caching corporation #{corporation_id}" }

    return unless corporation = @esi_client.request "/v4/corporations/#{corporation_id}/" do |response|
                    EveShoppingAPI::Models::Corporation.from_json response.body_io
                  end

    corporation.id = corporation_id

    unless EveShoppingAPI::Models::Corporation.exists? corporation_id
      Log.info { "Saving new corporation #{corporation_id}" }
      corporation.save!
    end

    corporation.alliance_id.try do |alliance_id|
      unless EveShoppingAPI::Models::Alliance.exists? alliance_id
        Log.info { "Saving new alliance #{alliance_id}" }

        return unless alliance = @esi_client.request "/v3/alliances/#{alliance_id}/" do |response|
                        EveShoppingAPI::Models::Alliance.from_json response.body_io
                      end

        alliance.id = alliance_id
        alliance.save!
      end
    end

    @corporation_alliance_map[corporation_id] = corporation.alliance_id
  end
end
