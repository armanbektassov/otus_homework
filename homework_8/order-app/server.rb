require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require './clients/rmq'
require './services/transaction_service'
require './models/order'
set :database_file, 'config/database.yml'


get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

get '/orders/:user_id' do
  user_id = params['user_id'].to_i
  orders = Order.where(user_id: user_id).pluck(:product_id, :quantity, :hour, :status)

  return orders.to_json
end

post '/orders/:user_id' do
  begin
    user_id = params['user_id'].to_i
    order = Order.new
    order.user_id = user_id
    order.product_id = params[:product_id].to_i
    order.quantity = params[:product_quantity].to_i
    order.hour = params[:delivery_hour].to_i
    order.status = 'proccessing'
    order.save!

    TransactionService.new(order).process

    return {id: order.id, product_id: order.product_id, hour: order.hour, status: order.status}.to_json
  rescue ActiveRecord::RecordInvalid => invalid
    halt(400, { errors: invalid.record.errors }.to_json)
  end
end

# Start RabbitMQ Consumer in a Thread
Rmq.new.start_rabbitmq_consumer