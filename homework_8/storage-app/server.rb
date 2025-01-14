require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
require './models/product'
require './clients/rmq'
set :database_file, 'config/database.yml'

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

get '/products/:id' do
  id = params['id'].to_i
  product = Product.select(:id, :product_name, :amount_fractional, :quantity).find_by(id: id)

  if product.present?
    return product.to_json
  else
    halt(400, { errors: 'Not found product'}.to_json)
  end
end

get '/products' do
  products = Product.select(:id, :product_name, :amount_fractional, :quantity).all

  products_with_amount = products.map do |product|
    {
      id: product.id,
      product_name: product.product_name,
      amount: product.amount_fractional / 100,
      quantity: product.quantity
    }
  end

  return products_with_amount.to_json
end

# Start RabbitMQ Consumer in a Thread
Rmq.new.start_rabbitmq_consumer
