class EveShoppingAPI::Models::SDE::Constellation < Granite::Base
  connection "eve-shopping"
  table "constellations"

  column id : Int32, primary: true, auto: false
  column name : String

  has_many systems : EveShoppingAPI::Models::SDE::System, primary_key: "constellation_id"
  belongs_to region : EveShoppingAPI::Models::SDE::Region, foreign_key: region_id : Int32
end
