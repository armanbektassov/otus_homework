require 'rest-client'

class Client

  def get_dishes(dish_id)
    RestClient.get(kitchen_url + '/dishes/' + dish_id.to_s) { |response, request, result, &block|
      response
    }
  end

  private

  def kitchen_url
    "#{ENV['KITCHEN_APP_URL']}"
  end
end
