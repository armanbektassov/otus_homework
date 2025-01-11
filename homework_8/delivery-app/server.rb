require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
require './clients/rmq'
require './models/hour'
set :database_file, 'config/database.yml'

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

get '/hours' do
  hours = Hour.select(:hour, :busy).all

  return hours.to_json
end

# Start RabbitMQ Consumer in a Thread
Rmq.new.start_rabbitmq_consumer
