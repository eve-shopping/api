require "athena"

require "./common"

require "./models/**"
require "./controllers/*"

Log.setup(:info, Log::IOBackend.new(formatter: SingleLineFormatter))

module EveShoppingAPI
  VERSION = "0.1.0"

  ART.run
end
