class ESIClient
  private ERROR_BACKOFF_LIMIT = 25

  @remaining_errors = 100
  @error_refresh = 60

  def request(path : String, headers : HTTP::Headers = HTTP::Headers.new, & : HTTP::Client::Response ->)
    self.with_client do |client|
      client.get(path, headers) do |response|
        data = unless response.success?
          response_body = response.body_io.gets_to_end

          Log.notice { "Request failed #{path}: #{response_body}" }

          if response.status.forbidden? && response_body.includes? "Forbidden"
            structure_id = path.match(/\/structures\/(\d+)\//).not_nil![1].to_i64

            EveShoppingAPI::Models::PrivateStructure.create(id: structure_id) unless EveShoppingAPI::Models::PrivateStructure.exists? structure_id
          end

          # TODO: Retry these
          raise Exception.new response_body if response.status.server_error?

          nil
        else
          yield response
        end

        @remaining_errors = response.headers["x-esi-error-limit-remain"].to_i
        @error_refresh = response.headers["x-esi-error-limit-reset"].to_i + 1

        data
      end
    end
  end

  def request_all(path : String, type : T.class) : Array(T) forall T
    self.with_client do |client|
      response = client.get(path)

      unless response.success?
        Log.notice { "Request failed #{path}: #{response.body}" }
        raise Exception.new response.body
      end

      data = T <= ASR::Serializable ? ASR.serializer.deserialize(Array(T), response.body, :json) : Array(T).from_json response.body
      pages = response.headers["x-pages"]?.try &.to_i

      Log.debug { "#{path} has #{pages} page(s)" }

      return data if pages.nil? || pages == 1

      (2..pages).each do |page|
        self.with_client do |inner_client|
          Log.debug { "Fetching page #{page} of #{path}" }

          path_with_page = "#{path}?page=#{page}"

          inner_client.get(path_with_page) do |response|
            unless response.success?
              Log.notice { "Request failed #{path_with_page}: #{response.body}" }
              raise Exception.new response.body_io.gets_to_end
            end

            data.concat ASR.serializer.deserialize(Array(T), response.body_io, :json)
          end
        end
      end

      data
    end
  end

  private def check_errors : Nil
    if @remaining_errors <= ERROR_BACKOFF_LIMIT
      Log.warn { "Reached error limit, sleeping #{@error_refresh}" }
      sleep @error_refresh
    end
  end

  private def with_client(& : HTTP::Client ->)
    self.check_errors

    yield HTTP::Client.new "esi.evetech.net", tls: true
  end
end
