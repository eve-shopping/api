struct EveShoppingAPI::Jobs::ContractItems
  Log = EveShoppingAPI::Jobs::Log.for "contract_items"

  @esi_client = ESIClient.new

  def execute
    EveShoppingAPI::AMQPConnectionFactory.channel do |ch|
      ch.basic_qos 200

      ch.basic_consume("contract.items", tag: "contract.items", block: true, no_ack: false, work_pool: 50) do |msg|
        contract_id = Int32.from_json msg.body_io

        headers = msg.properties.headers.not_nil!
        retry_count = headers.has_key?("x-death") ? headers["x-death"].as(Array)[0].as(AMQ::Protocol::Table)["count"].as(Int64) : 0
        retry_threshold = (threshold = headers["retry_threshold"]?) ? threshold.as(Int32) : 0

        Log.context.set retry: retry_count, retry_threshold: retry_threshold, contract_id: contract_id

        Log.info { "Fetching contract items" }

        @esi_client.request_all("/v1/contracts/public/items/#{contract_id}/", EveShoppingAPI::Models::ContractItem) do |contract_items|
          contract_items.each do |contract_item|
            contract_item.contract_id = contract_id

            # TODO: Remove this once https://github.com/esi/esi-issues/issues/1241 is resolved
            if !contract_item.is_blueprint_copy && !contract_item.material_efficiency.nil?
              contract_item.runs = -1
            end
          end

          EveShoppingAPI::Models::ContractItem.adapter.database.transaction do
            EveShoppingAPI::Models::ContractItem.import contract_items
          rescue ex : Exception
            Log.error(exception: ex) { "Failed to save items" }
            raise ex
          end
        end
      rescue ex : ::Exception
        if retry_threshold && retry_count.not_nil! < retry_threshold
          msg.reject
        else
          Log.warn(exception: ex) { "Failed to process message" }
          msg.ack
        end
      else
        msg.ack
      end
    end
  end
end
