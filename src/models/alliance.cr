class EveShoppingAPI::Models::SDE::Alliance < Granite::Base
  connection "eve-shopping"
  table "alliances"

  column id : Int32, primary: true, auto: false
  column name : String

  has_many corporations : EveShoppingAPI::Models::SDE::Corporation
end
