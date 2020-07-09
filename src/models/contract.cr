# Represents a location, such as a station or structure.
#
# TODO: Support private structures after https://github.com/esi/esi-issues/issues/1213 is fixed
class EveShoppingAPI::Models::Contract < Granite::Base
  include ASR::Serializable

  enum Status
    Outstanding
    InProgress
    FinishedIssuer
    FinishedContractor
    Finished
    Cancelled
    Rejected
    Failed
    Deleted
    Reversed
    Unknown
  end

  enum Type
    ItemExchange
    Auction
    Courier
    Loan
    Unknown
  end

  enum Availability
    Public
    Personal
    Corporation
    Alliance
  end

  enum Origin
    Public
    Personal
    Corporation
  end

  connection "eve-shopping"
  table "contracts"

  @[ASRA::Name(deserialize: "contract_id")]
  column id : Int64, primary: true, auto: false
  column title : String
  column status : EveShoppingAPI::Models::Contract::Status, converter: Granite::Converters::Enum(EveShoppingAPI::Models::Contract::Status, String)
  column type : EveShoppingAPI::Models::Contract::Type, converter: Granite::Converters::Enum(EveShoppingAPI::Models::Contract::Type, String)
  column availability : EveShoppingAPI::Models::Contract::Availability, converter: Granite::Converters::Enum(EveShoppingAPI::Models::Contract::Availability, String)
  column origin : EveShoppingAPI::Models::Contract::Origin, converter: Granite::Converters::Enum(EveShoppingAPI::Models::Contract::Origin, String)
  column for_corporation : Bool = false
  column days_to_complete : Int32?
  column collateral : Float64?
  column price : Float64?
  column reward : Float64?
  column buyout : Float64?
  column volume : Float64
  column date_issued : Time
  column date_expired : Time
  column date_accepted : Time?
  column date_completed : Time?

  belongs_to start_location : EveShoppingAPI::Models::Location, foreign_key: start_location_id : Int64
  belongs_to end_location : EveShoppingAPI::Models::Location, foreign_key: end_location_id : Int64?
  belongs_to assignee : EveShoppingAPI::Models::Caracter, foreign_key: asignee_id : Int32?
  belongs_to acceptor : EveShoppingAPI::Models::Caracter, foreign_key: acceptor_id : Int32?
  belongs_to issuer : EveShoppingAPI::Models::Caracter, foreign_key: issuer_id : Int32
  belongs_to issuer_corporation : EveShoppingAPI::Models::Corporation, foreign_key: issuer_corporation_id : Int32
  belongs_to issuer_alliance : EveShoppingAPI::Models::Alliance, foreign_key: issuer_alliance_id : Int32

  @[ASRA::PostDeserialize]
  private def normalize_data : Nil
    @price = nil if !self.type.item_exchange? && !self.type.auction?
    @buyout = nil unless self.type.auction?
    @collateral = @reward = @days_to_complete = nil unless self.type.courier?
  end
end
