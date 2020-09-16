require "athena-serializer"

Log.setup "athena.*", :info

require "./common"

module EveShoppingAPI::Jobs
  Log = ::Log.for "athena.worker"
end

require "./models/**"
require "./jobs/*"

spawn do
  loop do
    spawn EveShoppingAPI::Jobs::SyncPublicContractsJob.new.execute
    sleep 30.minutes
  end
end

sleep

# AMQP::Client.start("amqp://guest:guest@rabbitmq") do |c|
#   c.channel do |ch|
#     ch.basic_consume("contract.items", tag: "contract.items", block: true, no_ack: false) do |msg|
#       contract_id = Int32.from_json msg.body_io

#       Log.info { "Fetching items for contract #{contract_id}" }

#       contract_items = @esi_client.request_all("/v1/contracts/public/items/#{contract_id}/", EveShoppingAPI::Models::ContractItem)

#       contract_items.each do |contract_item|
#         contract_item.contract_id = contract_id

#         # TODO: Remove this once https://github.com/esi/esi-issues/issues/1241 is resolved
#         if !contract_item.is_blueprint_copy && !contract_item.material_efficiency.nil?
#           contract_item.runs = -1
#         end
#       end

#       EveShoppingAPI::Models::ContractItem.adapter.database.transaction do
#         EveShoppingAPI::Models::ContractItem.import contract_items
#       rescue ex : Exception
#         Log.error { "Failed to save items for contract #{contract_id}: #{ex.message}" }
#       end

#       puts msg.body_io
#       headers = msg.properties.headers.not_nil!
#       pp headers["x-death"].as(Array)[0].as(AMQ::Protocol::Table)["count"]

#       # headers = msg.properties.headers.not_nil!
#       # death_header = headers["x-death"]

#       # case death_header
#       # when Array then pp death_header[0]
#       # end

#       raise "err"
#     rescue ex : ::Exception
#       msg.reject
#     else
#       msg.ack
#     end
#   end
# end
