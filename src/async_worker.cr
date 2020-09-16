require "./worker"

spawn do
  EveShoppingAPI::Jobs::ContractItems.new.execute
end

sleep
