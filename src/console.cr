require "option_parser"

require "athena-serializer"

require "./common"
require "./models/**"

require "./commands/*"

Log.setup :debug

module EveShoppingAPI::Commands
  Log = ::Log.for "athena.console"
end

OptionParser.parse do |parser|
  parser.banner = "Usage: console [arguments]"
  parser.on("--sync_types", "Syncs SDE type data") { EveShoppingAPI::Commands::SyncTypes.execute }
  parser.on("--contract_items", "Syncs SDE type data") { EveShoppingAPI::Commands::ContractItems.execute }
end
