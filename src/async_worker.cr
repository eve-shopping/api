require "./worker"

Log.setup(:info, Log::IOBackend.new(formatter: SingleLineFormatter))

spawn do
  EveShoppingAPI::Jobs::ContractItems.new.execute
end

sleep
