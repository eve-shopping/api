require "athena"

class EveShoppingAPI::Controllers::Contoller < ART::Controller
  get "/ping" do
    "pong"
  end
end

module EveShoppingAPI
  VERSION = "0.1.0"

  ART.run
end
