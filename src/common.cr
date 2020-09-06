module EveShoppingAPI::Models::StringEnumConverter(E, T)
  extend self

  def to_db(value : E?) : Granite::Columns::Type
    return nil if value.nil?
    value.to_s.underscore.downcase
  end

  def from_rs(result : ::DB::ResultSet) : E?
    value = result.read(Bytes?)
    return nil if value.nil?
    E.parse? String.new value
  end
end

require "oauth2"

module EveShoppingAPI::ServiceAccount
  private SCOPES = %w(esi-universe.read_structures.v1)
  private class_getter refresh_token : String { File.read(ENV["SERVICE_ACCOUNT_REFRESH_TOKEN_FILE"]) + "==" }

  @@expires_at : Time = Time.utc
  @@access_token : OAuth2::AccessToken? = nil

  @@oauth_client : OAuth2::Client = OAuth2::Client.new(
    host: "login.eveonline.com",
    client_id: File.read(ENV["CLIENT_ID_FILE"]),
    client_secret: File.read(ENV["CLIENT_SECRET_FILE"]),
    authorize_uri: "/v2/oauth/authorize/",
    token_uri: "/v2/oauth/token",
  )

  def self.access_token : String
    if @@access_token.nil? || (@@expires_at - 1.minute < Time.utc)
      self.refresh_access_token
    end

    @@access_token.not_nil!.access_token
  end

  private def self.refresh_access_token
    @@access_token = @@oauth_client.get_access_token_using_refresh_token self.refresh_token
    @@expires_at = Time.utc + @@access_token.not_nil!.expires_in.not_nil!.seconds
  end
end
