require 'bunny'
require_relative '../handlers/handler'

class Rmq

  def initialize
  end

  def connect_to_rabbitmq
    max_retries = 10
    retries = 0

    begin
      puts "Attempting to connect to RabbitMQ..."
      connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@rabbitmq:5672')
      connection.start
      puts "Connected to RabbitMQ"
      return connection
    rescue Bunny::TCPConnectionFailedForAllHosts => e
      retries += 1
      if retries < max_retries
        puts "Retrying connection to RabbitMQ (#{retries}/#{max_retries})..."
        sleep(5) # Wait before retrying
        retry
      else
        puts "Failed to connect to RabbitMQ after #{max_retries} attempts: #{e.message}"
        raise
      end
    end
  end

  def start_rabbitmq_consumer
    Thread.new do

      connection = connect_to_rabbitmq
      connection.start

      channel = connection.create_channel
      queue = channel.queue('app.queue.kitchen')

      queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
        begin
          puts "Processing message: #{body}"

          Handler.new.handle_message(delivery_info, _properties, body)

          channel.ack(delivery_info.delivery_tag)
        rescue StandardError => e
          puts "Error: #{e.message}"
          channel.nack(delivery_info.delivery_tag, false, true) # Requeue
        end
      end

      trap('INT') { connection.close; exit }
      trap('TERM') { connection.close; exit }
    end
  end

  def send_message(data, queue, message_name)
    begin
      # Connect to RabbitMQ
      connection = connect_to_rabbitmq
      connection.start

      channel = connection.create_channel
      queue = channel.queue(queue)

      # Send a message to RabbitMQ
      queue.publish(
        data.to_json,
        headers: { message_name: message_name }
      )
    ensure
      # Ensure the connection is closed
      connection&.close
    end
  end
end
