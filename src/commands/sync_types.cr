module EveShoppingAPI::Commands::SyncTypes
  Log = EveShoppingAPI::Commands::Log.for "sync_types"

  @@esi_client = ESIClient.new

  def self.execute : Nil
    Log.info { "Syncing type data" }

    self.execute_categories
    self.execute_groups
    self.execute_types
  end

  private def self.execute_categories : Nil
    stored_ids = EveShoppingAPI::Models::SDE::Category.all.map &.id
    upstream_ids = @@esi_client.request_all("/v1/universe/categories/", Int32)

    new_ids = upstream_ids - stored_ids

    Log.info { "Saving #{new_ids.size} new categories" }
    new_ids.each do |id|
      category = @@esi_client.request "/v1/universe/categories/#{id}/" do |response|
        EveShoppingAPI::Models::SDE::Category.from_json response.body_io
      end

      unless category
        Log.error { "Failed to fetch category #{id}" }
        exit(1)
      end

      category.id = id
      category.save!
    end
  end

  private def self.execute_groups : Nil
    stored_ids = EveShoppingAPI::Models::SDE::Group.all.map &.id
    upstream_ids = @@esi_client.request_all("/v1/universe/groups/", Int32)

    new_ids = upstream_ids - stored_ids

    Log.info { "Saving #{new_ids.size} new groups" }
    new_ids.each do |id|
      group = @@esi_client.request "/v1/universe/groups/#{id}/" do |response|
        EveShoppingAPI::Models::SDE::Group.from_json response.body_io
      end

      unless group
        Log.error { "Failed to fetch group #{id}" }
        exit(1)
      end

      group.id = id
      group.save!
    end
  end

  private def self.execute_types : Nil
    stored_ids = EveShoppingAPI::Models::SDE::Type.all.map &.id
    upstream_ids = @@esi_client.request_all("/v1/universe/types/", Int32)

    new_ids = upstream_ids - stored_ids

    Log.info { "Saving #{new_ids.size} new types" }
    new_ids.each do |id|
      type = @@esi_client.request "/v3/universe/types/#{id}/" do |response|
        EveShoppingAPI::Models::SDE::Type.from_json response.body_io
      end

      unless type
        Log.error { "Failed to fetch type #{id}" }
        exit(1)
      end

      type.id = id
      type.save!
    end
  end
end
