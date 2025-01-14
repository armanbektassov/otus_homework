require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bunny'
require './models/wallet'
require './clients/rmq'
set :database_file, 'config/database.yml'

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

# Start RabbitMQ Consumer in a Thread
Rmq.new.start_rabbitmq_consumer