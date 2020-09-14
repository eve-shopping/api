require "mosquito"
require "../jobs/contract_items"

module EveShoppingAPI::Commands::ContractItems
  Log = EveShoppingAPI::Commands::Log.for "contract_items"

  @@esi_client = ESIClient.new

  def self.execute : Nil
    EveShoppingAPI::Models::Contract.all.each do |contract|
      EveShoppingAPI::Jobs::ContractItems.new(contract.id).enqueue if contract.type.item_exchange? || contract.type.auction?
    end
  end
end
