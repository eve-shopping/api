require "./worker"

Log.setup :info

spawn do
  loop do
    spawn EveShoppingAPI::Jobs::SyncPublicContractsJob.new.execute
    sleep 30.minutes
  end
end

sleep
