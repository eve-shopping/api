class EveShoppingAPI::Models::Corporation < Granite::Base
  connection "eve-shopping"
  table "corporations"

  column id : Int32, primary: true, auto: false
  column name : String

  getter alliance_id : Int32?
end
