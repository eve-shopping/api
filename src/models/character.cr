class EveShoppingAPI::Models::SDE::Character < Granite::Base
  connection "eve-shopping"
  table "characters"

  column id : Int32, primary: true, auto: false
  column name : String

  belongs_to corporation : EveShoppingAPI::Models::SDE::Corporation, foreign_key: corporation_id : Int32
end
