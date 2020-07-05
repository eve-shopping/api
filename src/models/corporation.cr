class EveShoppingAPI::Models::SDE::Corporation < Granite::Base
  connection "eve-shopping"
  table "corporations"

  column id : Int32, primary: true, auto: false
  column name : String

  has_many characters : EveShoppingAPI::Models::SDE::Character, primary_key: "corporation_id"
  belongs_to alliance : EveShoppingAPI::Models::SDE::Alliance, foreign_key: alliance_id : Int32
end
