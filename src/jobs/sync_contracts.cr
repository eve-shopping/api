class SyncContractsJob < Mosquito::PeriodicJob
  run_every 30.minutes

  def perform
    regions = Channel(Bool).new
    headers = HTTP::Headers{"authorization" => "Bearer #{TOKEN}"}

    EveShoppingAPI::Models::SDE::Region.all.first(1).each do |region|
      spawn do
        contract_data = Channel(Bool).new

        Log.debug { "Resolving region: #{region.id}" }

        public_contracts = ASR.serializer.deserialize Array(EveShoppingAPI::Models::Contract), HTTP::Client.get("https://esi.evetech.net/v1/contracts/public/#{region.id}", headers: headers).body, :json

        location_ids = Set(Int64).new

        public_contracts.first(1).each do |contract|
          # Fix some data before processing it
          contract.availability = :public
          contract.status = :outstanding
          contract.origin = :public

          # structure = EveShoppingAPI::Models::Location.from_json HTTP::Client.get("https://esi.evetech.net/v1/universe/structures/#{contract.start_location_id}", headers: headers).body

          pp contract
          # pp structure

          # location_ids.add contract.start_location_id
          # contract.save
        end

        regions.send true
      end
    end

    1.times do
      regions.receive
    end
  end
end
