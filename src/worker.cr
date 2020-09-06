require "athena-serializer"

require "mosquito"
require "granite"
require "granite/adapter/pg"

Granite::Connections << Granite::Adapter::Pg.new(name: "eve-shopping", url: %(postgres://eve-shopping:#{File.read ENV["DB_PASSWORD_FILE"]}@db:5432/eve-shopping))

Log.setup :info

require "./common"

require "./models/**"
require "./jobs/*"

Mosquito::Runner.start
