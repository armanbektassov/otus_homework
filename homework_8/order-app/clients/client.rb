require 'rest-client'

class Client

  def get_product(product_id)
    RestClient.get(storage_url + '/products/' + product_id.to_s) { |response, request, result, &block|
      response
    }
  end

  private

  def storage_url
    "#{ENV['STORAGE_APP_URL']}"
  end
end
