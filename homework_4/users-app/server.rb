require 'sinatra'
require 'json'
require 'sinatra/activerecord'
set :database_file, 'config/database.yml'

class User < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
end

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

## Index route
get '/users' do
  return User.select('id', 'username', 'firstname', 'lastname').all.to_json
end

## Create Route
post '/users' do
  body = JSON.parse(request.body.read, symbolize_names: true)
  user = User.create(body)

  if user
    return user.to_json
  else
    halt 500
  end
end

## Update Route
put '/users/:id' do
  id = params['id'].to_i
  user = User.find(id)
  body = JSON.parse(request.body.read, symbolize_names: true)

  if user
    user.update(body)
    return user.to_json
  else
    halt 404
  end
end

## Destroy Route
delete '/users/:id' do
  id = params['id'].to_i
  user = User.find(id)

  if user
    user.destroy
    return user.to_json
  else
    halt 404
  end
end
