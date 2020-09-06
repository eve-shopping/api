# Stores structures that are not currently resolveable.
# Allows keeping track of private structures in order to prevent needing to try and resolve them every time.
class EveShoppingAPI::Models::PrivateStructure < Granite::Base
  connection "eve-shopping"
  table "private_structures"

  column id : Int64, primary: true, auto: false
  column created_at : Time
end
