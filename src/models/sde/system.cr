class EveShoppingAPI::Models::SDE::System < Granite::Base
  connection "eve-shopping"
  table "systems"

  column id : Int32, primary: true, auto: false
  column name : String
  column security : Float64

  belongs_to constellation : EveShoppingAPI::Models::SDE::Constellation, foreign_key: constellation_id : Int32
  belongs_to region : EveShoppingAPI::Models::SDE::Region, foreign_key: region_id : Int32
end
