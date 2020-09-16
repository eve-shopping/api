require "amqp-client"

module EveShoppingAPI::Commands::RabbitStructure
  def self.execute : Nil
    AMQP::Client.start("amqp://guest:guest@rabbitmq") do |c|
      c.channel do |ch|
        # Retry
        ch.exchange_declare "retry.headers", "headers"
        ch.queue_declare "retry", args: AMQP::Client::Arguments.new({"x-message-ttl" => 15_000, "x-dead-letter-exchange" => "amq.topic"})
        ch.queue_bind "retry", "retry.headers", ""

        # Contract Processing
        ch.queue_declare "contract.items", args: AMQP::Client::Arguments.new({"x-dead-letter-exchange" => "retry.headers"})
        ch.queue_bind "contract.items", "amq.topic", "contract.items"
      end
    end
  end
end
