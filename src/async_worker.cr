require "./worker"

Log.setup :info

spawn do
  EveShoppingAPI::Jobs::ContractItems.new.execute
end

sleep
