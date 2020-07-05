class EveShoppingAPI::Models::SDE::Category < Granite::Base
  connection "eve-shopping"
  table "categories"

  column id : Int32, primary: true, auto: false
  column name : String
  column published : Bool

  has_many groups : EveShoppingAPI::Models::SDE::Group
end
