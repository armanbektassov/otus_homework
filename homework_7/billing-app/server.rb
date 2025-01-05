require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
set :database_file, 'config/database.yml'

class Wallet < ActiveRecord::Base
  validates :user_id, presence: true, uniqueness: true
  validates :amount_fractional, presence: true, length: { minimum: 0 }
end

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

get '/billing/:user_id' do
  user_id = params['user_id'].to_i
  wallet = Wallet.select(:amount_fractional).find_by(user_id: user_id)

  if wallet.present?
    return { wallet: wallet.amount_fractional / 100 }.to_json
  else
    halt(400, { errors: 'Not found wallet'}.to_json)
  end
end

put '/billing/:user_id' do
  begin
    user_id = params['user_id'].to_i

    wallet = Wallet.find_by(user_id: user_id)
    wallet.amount_fractional = wallet.amount_fractional + params['amount'].to_i * 100
    wallet.save!

    return { wallet: wallet.amount_fractional / 100 }.to_json
  rescue ActiveRecord::RecordInvalid => invalid
    halt(400, { errors: invalid.record.errors }.to_json)
  end
end

post '/billing/:user_id' do
  begin
    user_id = params['user_id'].to_i

    wallet = Wallet.new({
      user_id: user_id,
      amount_fractional: 0
   })
    wallet.save!

    return { wallet: 0 }.to_json
  rescue ActiveRecord::RecordInvalid => invalid
    halt(400, { errors: invalid.record.errors }.to_json)
  end
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
    queue = channel.queue('billing_queue')

    puts "Subscribing to queue: billing_queue"

    queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
      begin
        puts "Processing message: #{body}"

        data = JSON.parse(body, symbolize_names: true)
        wallet = Wallet.find_by(user_id: data[:user_id])
        if wallet.present? && wallet.amount_fractional >= data[:amount_fractional].to_i
          wallet.amount_fractional -= data[:amount_fractional].to_i
          wallet.save!

          send_message({ order_id: data[:order_id], user_id: data[:user_id], amount: data[:amount_fractional], success: true })
        else
          send_message({ order_id: data[:order_id], user_id: data[:user_id], amount: data[:amount_fractional], success: false })
        end

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

# Helper Method to Send Messages
def send_message(data)
  begin
    connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@rabbitmq:5672')
    connection.start

    channel = connection.create_channel
    queue = channel.queue('notification_queue')

    queue.publish(data.to_json)
  ensure
    connection&.close
  end
end