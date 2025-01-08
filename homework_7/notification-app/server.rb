require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
set :database_file, 'config/database.yml'

class Notification < ActiveRecord::Base
  validates :user_id, presence: true
  validates :notification, presence: true
end

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

get '/notifications/:user_id' do
  user_id = params['user_id'].to_i
  notifications = Notification.where(user_id: user_id).pluck(:notification)

  return notifications.to_json
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

# RabbitMQ Consumer Logic
def start_rabbitmq_consumer
  Thread.new do

    connection = connect_to_rabbitmq
    connection.start

    channel = connection.create_channel
    queue = channel.queue('notification_queue')

    puts "Subscribing to queue: notification_queue"

    queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
      begin
        puts "Processing message: #{body}"

        data = JSON.parse(body, symbolize_names: true)

        notification = Notification.new(user_id: data[:user_id])
        notification.notification = 'Successfully! Order #' + data[:order_id].to_s + ' was paid' if data[:success]
        notification.notification = 'Failed! Order #' + data[:order_id].to_s + ' was not paid' unless data[:success]
        notification.save!

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

# Start RabbitMQ Consumer in a Thread
start_rabbitmq_consumer
