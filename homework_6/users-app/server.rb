require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'bcrypt'
set :database_file, 'config/database.yml'

class User < ActiveRecord::Base
  include BCrypt
  validates :username, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :firstname, presence: true
  validates :lastname, presence: true

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

get '/health' do
  raise 'Can`t connect to database' unless ActiveRecord::Base.connection.execute('select 1')
  return { "status": 'OK' }.to_json
end

## Get profile
get '/profile/:id' do
  id = params['id'].to_i
  user = User.select(:id, :username, :firstname, :lastname).find_by(id: id)

  if user.present?
    return user.to_json
  else
    halt(400, { errors: 'Not found user'}.to_json)
  end
end

## Register
post '/register' do
  begin
    user = User.new(params)
    user.password = params[:password]
    user.save!

    return  User.select(:id, :username, :firstname, :lastname).find(user.id).to_json
  rescue ActiveRecord::RecordInvalid => invalid
    halt(400, { errors: invalid.record.errors }.to_json)
  end
end

post '/login' do
  user = User.find_by(username: params[:username])
  if user.present? && user.password == params[:password]
    return user.to_json
  else
    halt(400, { errors: 'Incorrect username or password'}.to_json)
  end
end

## Update user
put '/users/:id' do
  id = params['id'].to_i
  user = User.find_by(id: id)

  if user.present?
    user.update({
      :firstname => params[:firstname],
      :lastname => params[:lastname],
    })
    return User.select(:id, :username, :firstname, :lastname).find(id).to_json
  else
    halt(400, { errors: 'Not found user'}.to_json)
  end
end
