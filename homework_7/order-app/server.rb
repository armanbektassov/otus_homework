require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
set :database_file, 'config/database.yml'

class Order < ActiveRecord::Base
  validates :user_id, presence: true
  validates :order_name, presence: true
  validates :amount_fractional, presence: true, length: { minimum: 0 }
end

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

post '/orders/:user_id' do
  begin
    user_id = params['user_id'].to_i
    order = Order.new
    order.user_id = user_id
    order.order_name = params[:order_name]
    order.amount_fractional = params[:amount].to_i * 100
    order.save!

    send_message({order_id: order.id, user_id: user_id, amount_fractional: order.amount_fractional})

    return {id: order.id, order_name: order.order_name, amount_fractional: order.amount_fractional/100}.to_json
  rescue ActiveRecord::RecordInvalid => invalid
    halt(400, { errors: invalid.record.errors }.to_json)
  end
end

def send_message(data)
  begin
    # Connect to RabbitMQ
    connection = Bunny.new(ENV['RABBITMQ_URL'] || 'amqp://guest:guest@rabbitmq:5672')
    connection.start

    channel = connection.create_channel
    queue = channel.queue('billing_queue')

    # Send a message to RabbitMQ
    queue.publish(data.to_json)
  ensure
    # Ensure the connection is closed
    connection&.close
  end
end
