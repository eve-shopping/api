require "athena-serializer"

Log.setup "athena.*", :info

require "./common"

module EveShoppingAPI::Jobs
  Log = ::Log.for "athena.worker"
end

require "./models/**"
require "./jobs/*"
