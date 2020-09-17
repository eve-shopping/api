require "athena-serializer"

require "./common"

module EveShoppingAPI::Jobs
  Log = ::Log.for "athena.worker"
end

require "./models/**"
require "./jobs/*"
