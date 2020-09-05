class EveShoppingAPI::Models::Character < Granite::Base
  connection "eve-shopping"
  table "characters"

  column id : Int32, primary: true, auto: false
  column name : String

  getter corporation_id : Int32?
end
