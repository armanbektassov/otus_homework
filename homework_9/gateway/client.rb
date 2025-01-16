require 'rest-client'

class Client

  def register(data)
    RestClient.post(user_url + '/register', data) { |response, request, result, &block|
      response
    }
  end

  def login(data)
    RestClient.post(user_url + '/login', data) { |response, request, result, &block|
      response
    }
  end

  def profile(id)
    RestClient.get(user_url + '/profile/' + id.to_s) { |response, request, result, &block|
      response
    }
  end

  def update_user(id, data)
    RestClient.put(user_url + '/users/' + id.to_s, data) { |response, request, result, &block|
      response
    }
  end

  def billing(id)
    RestClient.post(billing_url + '/billing/' + id.to_s, {}) { |response, request, result, &block|
      response
    }
  end

  def change_billing(id, data)
    RestClient.put(billing_url + '/billing/' + id.to_s, data) { |response, request, result, &block|
      response
    }
  end

  def get_billing(id)
    RestClient.get(billing_url + '/billing/' + id.to_s) { |response, request, result, &block|
      response
    }
  end

  def order(id, data)
    RestClient.post(order_url + '/orders/' + id.to_s, data) { |response, request, result, &block|
      response
    }
  end

  def get_orders(id)
    RestClient.get(order_url + '/orders/' + id.to_s) { |response, request, result, &block|
      response
    }
  end

  def get_notification(id)
    RestClient.get(notification_url + '/notifications/' + id.to_s) { |response, request, result, &block|
      response
    }
  end

  def get_couriers
    RestClient.get(delivery_url + '/hours') { |response, request, result, &block|
      response
    }
  end

  def get_products
    RestClient.get(storage_url + '/products') { |response, request, result, &block|
      response
    }
  end

  private

  def user_url
    "#{ENV['ACCOUNT_APP_URL']}"
  end

  def billing_url
    "#{ENV['BILLING_APP_URL']}"
  end

  def order_url
    "#{ENV['ORDER_APP_URL']}"
  end

  def notification_url
    "#{ENV['NOTIFICATION_APP_URL']}"
  end

  def delivery_url
    "#{ENV['DELIVERY_APP_URL']}"
  end

  def storage_url
    "#{ENV['STORAGE_APP_URL']}"
  end
end
