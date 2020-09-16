require "athena"

require "./common"

require "./models/**"
require "./controllers/*"

Log.setup "athena.*", :info

module EveShoppingAPI
  VERSION = "0.1.0"

  ART.run
end
