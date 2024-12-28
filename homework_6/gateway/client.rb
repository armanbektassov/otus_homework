require 'rest-client'

class Client

  def register(data)
    RestClient.post(base_url + '/register', data) { |response, request, result, &block|
      response
    }
  end

  def login(data)
    RestClient.post(base_url + '/login', data) { |response, request, result, &block|
      response
    }
  end

  def profile(id)
    RestClient.get(base_url + '/profile/' + id.to_s) { |response, request, result, &block|
      response
    }
  end

  def update_user(id, data)
    RestClient.put(base_url + '/users/' + id.to_s, data) { |response, request, result, &block|
      response
    }
  end

  private

  def base_url
    "#{ENV['USERS_APP_URL']}"
  end
end
