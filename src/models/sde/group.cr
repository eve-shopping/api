class EveShoppingAPI::Models::SDE::Group < Granite::Base
  connection "eve-shopping"
  table "groups"

  column id : Int32, primary: true, auto: false
  column name : String
  column published : Bool

  has_many types : EveShoppingAPI::Models::SDE::Type, primary_key: "group_id"
  belongs_to category : EveShoppingAPI::Models::SDE::Category, foreign_key: category_id : Int32
end
