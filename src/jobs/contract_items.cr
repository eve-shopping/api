class EveShoppingAPI::Jobs::ContractItems < Mosquito::QueuedJob
  Log = EveShoppingAPI::Jobs::Log.for "contract_items"

  params contract_id : Int32

  @esi_client = ESIClient.new

  def perform
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
    end
  end
end
