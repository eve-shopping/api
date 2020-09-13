class EveShoppingAPI::Jobs::ContractItems < Mosquito::QueuedJob
  Log = EveShoppingAPI::Jobs::Log.for "contract_items"

  params contract_id : Int32

  @esi_client = ESIClient.new

  def perform
    Log.info { "Fetching items for contract #{contract_id}" }

    contract_items = @esi_client.request_all("/v1/contracts/public/items/#{contract_id}/", EveShoppingAPI::Models::ContractItem)

    contract_items.each do |contract_item|
      contract_item.contract_id = contract_id
    end

    EveShoppingAPI::Models::ContractItem.adapter.database.transaction do
      EveShoppingAPI::Models::ContractItem.import contract_items
    rescue ex : Exception
      Log.error { "Failed to save items for contract #{contract_id}: #{ex.message}" }
    end
  end
end
