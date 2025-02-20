require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
require './models/dish'
require './clients/rmq'
set :database_file, 'config/database.yml'

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

get '/dishes/:id' do
  id = params['id'].to_i
  dish = Dish.select(:id, :dish_name, :amount_fractional, :quantity).find_by(id: id)

  if dish.present?
    return dish.to_json
  else
    halt(400, { errors: 'Not found dish'}.to_json)
  end
end

get '/dishes' do
  dishes = Dish.select(:id, :dish_name, :amount_fractional, :quantity).all

  dishes_with_amount = dishes.map do |dish|
    {
      id: dish.id,
      dish_name: dish.dish_name,
      amount: dish.amount_fractional / 100,
      quantity: dish.quantity
    }
  end

  return dishes_with_amount.to_json
end

# Start RabbitMQ Consumer in a Thread
Rmq.new.start_rabbitmq_consumer
