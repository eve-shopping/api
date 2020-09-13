require "athena-serializer"

require "mosquito"

Log.setup :info

require "./common"

module EveShoppingAPI::Jobs
  Log = ::Log.for "athena.worker"
end

require "./models/**"
require "./jobs/*"

Mosquito::Runner.start
