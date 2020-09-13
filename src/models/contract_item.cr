class EveShoppingAPI::Models::ContractItem < Granite::Base
  connection "eve-shopping"
  table "contract_items"

  @[JSON::Field(key: "record_id")]
  column id : Int64, primary: true, auto: false
  column quantity : Int32
  column is_included : Bool
  column item_id : Int64?
  column is_blueprint_copy : Bool = false
  column runs : Int32?
  column material_efficiency : Int32?
  column time_efficiency : Int32?

  belongs_to contract : EveShoppingAPI::Models::Contract, foreign_key: contract_id : Int32
  belongs_to type : EveShoppingAPI::Models::SDE::Type, foreign_key: type_id : Int32
end
