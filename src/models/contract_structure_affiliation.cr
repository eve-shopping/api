# Represents a location, such as a station or structure.
#
# TODO: Support private structures after https://github.com/esi/esi-issues/issues/1213 is fixed
class EveShoppingAPI::Models::ContractStructureAffiliation < Granite::Base
  connection "eve-shopping"
  table "contract_structure_affiliations"

  enum Origin
    Start
    End
  end

  column contract_id : Int32, primary: true, auto: false
  column origin : EveShoppingAPI::Models::ContractStructureAffiliation::Origin, converter: EveShoppingAPI::Models::StringEnumConverter(EveShoppingAPI::Models::ContractStructureAffiliation::Origin, String)

  belongs_to structure : EveShoppingAPI::Models::Structure, foreign_key: structure_id : Int64
  belongs_to corporation : EveShoppingAPI::Models::Corporation, foreign_key: corporation_id : Int32
  belongs_to alliance : EveShoppingAPI::Models::Alliance, foreign_key: alliance_id : Int32?
end
