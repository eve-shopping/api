class EveShoppingAPI::Models::Alliance < Granite::Base
  connection "eve-shopping"
  table "alliances"

  column id : Int32, primary: true, auto: false
  column name : String
end
