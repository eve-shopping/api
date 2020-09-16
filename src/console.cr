require "option_parser"

require "athena-serializer"

require "./common"
require "./models/**"

require "./commands/*"

Log.setup "athena.*", :info

module EveShoppingAPI::Commands
  Log = ::Log.for "athena.console"
end

OptionParser.parse do |parser|
  parser.banner = "Usage: console [arguments]"
  parser.on("--sync_types", "Syncs SDE type data") { EveShoppingAPI::Commands::SyncTypes.execute }
  parser.on("--rabbit_structure", "Scaffolds the RabbitMQ queues") { EveShoppingAPI::Commands::RabbitStructure.execute }
end
