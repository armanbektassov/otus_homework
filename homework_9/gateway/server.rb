require 'json'
require 'jwt'
require 'sinatra/base'
require './client'

class JwtAuth

  def initialize app
    @app = app
  end

  def call env
    begin
      options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      payload, header = JWT.decode bearer, ENV['JWT_SECRET'], true, options

      env[:scopes] = payload['scopes']
      env[:user] = payload['user']

      @app.call env
    rescue JWT::DecodeError
      [401, { 'Content-Type' => 'text/plain' }, ['A token must be passed.']]
    rescue JWT::ExpiredSignature
      [403, { 'Content-Type' => 'text/plain' }, ['The token has expired.']]
    rescue JWT::InvalidIssuerError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid issuer.']]
    rescue JWT::InvalidIatError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
    end
  end

end

class Api < Sinatra::Base

  use JwtAuth

  def initialize
    super

    @client = Client.new
  end

  get '/profile' do
    scopes, user = request.env.values_at :scopes, :user

    if scopes.include?('profile_user')
      response = @client.profile(user['id'])
      if response.code.to_s == '200'

        billing_response = @client.get_billing(user['id'])
        if billing_response.code.to_s == '200'
          content_type :json
          JSON.parse(response, {:symbolize_names => true}).merge(JSON.parse(billing_response, {:symbolize_names => true})).to_json
        else
          halt(400, billing_response)
        end
      else
        halt(400, response)
      end
    else
      halt 401
    end
  end

  post '/billing' do
    scopes, user = request.env.values_at :scopes, :user

    if scopes.include?('billing_user')
      response = @client.change_billing(user['id'], params)
      if response.code.to_s == '200'
        content_type :json
        JSON.parse(response, {:symbolize_names => true}).to_json
      else
        halt(400, response)
      end
    else
      halt 401
    end
  end

  post '/orders' do
    scopes, user = request.env.values_at :scopes, :user

    halt(400, 'There is no IDEMPOTENCY_KEY') if request.env['HTTP_IDEMPOTENCY_KEY'] == ''

    if scopes.include?('order_user')
      idempotency_key = request.env['HTTP_IDEMPOTENCY_KEY'].to_s
      response = @client.order(user['id'], params.merge!(idempotency_key: idempotency_key))
      if response.code.to_s == '200'
        content_type :json
        JSON.parse(response, {:symbolize_names => true}).to_json
      else
        halt(400, response)
      end
    else
      halt 401
    end
  end

  get '/orders' do
    scopes, user = request.env.values_at :scopes, :user

    if scopes.include?('order_user')
      response = @client.get_orders(user['id'])
      if response.code.to_s == '200'
        content_type :json
        JSON.parse(response, {:symbolize_names => true}).to_json
      else
        halt(400, response)
      end
    else
      halt 401
    end
  end

  get '/notifications' do
    scopes, user = request.env.values_at :scopes, :user

    if scopes.include?('notification_user')

      response = @client.get_notification(user['id'])
      if response.code.to_s == '200'
          content_type :json
          JSON.parse(response, {:symbolize_names => true}).to_json
      else
        halt(400, response)
      end
    else
      halt 401
    end
  end

end

class Public < Sinatra::Base

  def initialize
    super

    @client = Client.new
  end

  get '/health' do
    content_type :json
    { "status": 'OK' }.to_json
  end

  post '/login' do
    response = @client.login(params)

    if response.code.to_s == '200'
      user = JSON.parse(response, {:symbolize_names => true})

      content_type :json
      { token: token(user[:id], user[:username]) }.to_json
    else
      halt(400, response)
    end
  end

  post '/register' do
    response = @client.register(params)

    if response.code.to_s == '200'
      user = JSON.parse(response, {:symbolize_names => true})
      billing_response = @client.billing(user[:id])

      if billing_response.code.to_s == '200'
        content_type :json
        user.merge({ wallet: 0 }).to_json
      else
        halt(400, response)
      end
    else
      halt(400, response)
    end
  end

  get '/couriers' do
    response = @client.get_couriers
    if response.code.to_s == '200'
      content_type :json
      JSON.parse(response, {:symbolize_names => true}).to_json
    else
      halt(400, response)
    end
  end

  get '/products' do
    response = @client.get_products
    if response.code.to_s == '200'
      content_type :json
      JSON.parse(response, {:symbolize_names => true}).to_json
    else
      halt(400, response)
    end
  end

  def token (id, username)
    JWT.encode payload(id, username), ENV['JWT_SECRET'], 'HS256'
  end

  def payload (id, username)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: ['profile_user', 'billing_user', 'order_user'],
      user: {
        id: id,
        username: username
      }
    }
  end

end

