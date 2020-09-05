# TODO: Support private structures after https://github.com/esi/esi-issues/issues/1213 is fixed
class EveShoppingAPI::Models::Structure < Granite::Base
  connection "eve-shopping"
  table "structures"

  column id : Int64, primary: true, auto: false
  column name : String
  column created_at : Time
  column updated_at : Time
  column deleted_at : Time?

  @[JSON::Field(key: "solar_system_id")]
  belongs_to system : EveShoppingAPI::Models::SDE::System, foreign_key: system_id : Int32
  belongs_to type : EveShoppingAPI::Models::SDE::Type, foreign_key: type_id : Int32

  getter owner_id : Int32?
end
