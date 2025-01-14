require_relative '../clients/rmq'
require_relative '../models/product'

class Handler

  def initialize
    @rmq = Rmq.new
  end

  def handle_message(delivery_info, properties, payload)
    message_name = properties.headers['message_name']
    data = JSON.parse(payload, symbolize_names: true)

    puts "Received message: #{message_name}"
    puts "Routing Key: #{delivery_info.routing_key}"
    puts "Payload: #{data}"

    product = Product.find(data[:product_id])

    case message_name
    when 'BookProductCommand'
      if product.quantity >= data[:quantity].to_i
        product.quantity = product.quantity - data[:quantity].to_i
        product.save!

        @rmq.send_message(data, 'app.queue.order', 'ProductBookedEvent')
      else
        @rmq.send_message(data, 'app.queue.order', 'ProductUnbookedEvent')
      end
    when 'UnbookProductCommand'
      product.quantity = product.quantity + data[:quantity].to_i
      product.save!

      @rmq.send_message(data, 'app.queue.order', 'ProductUnbookedEvent')
    else
      puts "Unhandled message type: #{message_name}"
    end if product.present?
  end
end