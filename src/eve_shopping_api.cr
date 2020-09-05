require "athena"

require "granite"
require "granite/adapter/pg"

Granite::Connections << Granite::Adapter::Pg.new(name: "eve-shopping", url: %(postgres://eve-shopping:#{File.read ENV["DB_PASSWORD_FILE"]}@db:5432/eve-shopping))

require "./common"

require "./models/**"
require "./controllers/*"

Log.setup :debug

module EveShoppingAPI
  VERSION = "0.1.0"

  ART.run
end
