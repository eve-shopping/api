struct EveShoppingAPI::Jobs::ContractItems
  Log = EveShoppingAPI::Jobs::Log.for "contract_items"

  @esi_client = ESIClient.new

  def execute
    EveShoppingAPI::AMQPConnectionFactory.channel do |ch|
      ch.basic_qos 100

      ch.basic_consume("contract.items", tag: "contract.items", block: true, no_ack: false, work_pool: 20) do |msg|
        contract_id = Int32.from_json msg.body_io

        Log.info { "Fetching items for contract #{contract_id}" }

        contract_items = @esi_client.request_all("/v1/contracts/public/items/#{contract_id}/", EveShoppingAPI::Models::ContractItem)

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
          Log.error { "Failed to save items for contract #{contract_id}: #{ex.message}" }
          raise ex
        end
      rescue ex : ::Exception
        msg.reject
      else
        msg.ack
      end
    end
  end
end
