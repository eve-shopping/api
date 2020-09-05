class EveShoppingAPI::Models::SDE::Station < Granite::Base
  connection "eve-shopping"
  table "stations"

  column id : Int64, primary: true, auto: false
  column name : String

  belongs_to system : EveShoppingAPI::Models::SDE::System, foreign_key: system_id : Int32
  belongs_to type : EveShoppingAPI::Models::SDE::Type, foreign_key: type_id : Int32
end
