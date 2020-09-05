module EveShoppingAPI::Models::StringEnumConverter(E, T)
  extend self

  def to_db(value : E?) : Granite::Columns::Type
    return nil if value.nil?
    value.to_s.underscore.downcase
  end

  def from_rs(result : ::DB::ResultSet) : E?
    value = result.read(T?)
    return nil if value.nil?
    E.parse? value
  end
end
