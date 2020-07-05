class EveShoppingAPI::Models::SDE::Region < Granite::Base
  connection "eve-shopping"
  table "regions"

  column id : Int32, primary: true, auto: false
  column name : String

  has_many constellations : EveShoppingAPI::Models::SDE::Constellation
  has_many systems : EveShoppingAPI::Models::SDE::System, primary_key: "region_id"
end
