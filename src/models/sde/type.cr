class EveShoppingAPI::Models::SDE::Type < Granite::Base
  connection "eve-shopping"
  table "types"

  column id : Int32, primary: true, auto: false
  column name : String
  column description : String
  column volume : Float32
  column published : Bool

  belongs_to group : EveShoppingAPI::Models::SDE::Group, foreign_key: group_id : Int32
end
