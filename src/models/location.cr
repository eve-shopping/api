# Represents a location, such as a station or structure.
#
# TODO: Support private structures after https://github.com/esi/esi-issues/issues/1213 is fixed
class EveShoppingAPI::Models::Location < Granite::Base
  connection "eve-shopping"
  table "locations"

  # Returns only `#structure?` locations.
  def self.structures
    self.all "WHERE id > #{Int32::MAX}"
  end

  column id : Int64, primary: true, auto: false
  column name : String
  column etag : String
  column created_at : Time
  column updated_at : Time
  column deleted_at : Time?

  belongs_to system : EveShoppingAPI::Models::SDE::System, foreign_key: system_id : Int32
  belongs_to type : EveShoppingAPI::Models::SDE::Type, foreign_key: type_id : Int32

  # Returns `true` if `self` represents a player owned structure, otherwise `false`.
  def structure? : Bool
    @id.not_nil! > Int32::MAX
  end

  # Returns `true` if `self` represents an `NPC` station, otherwise `false`.
  def station? : Bool
    !self.structure?
  end
end
