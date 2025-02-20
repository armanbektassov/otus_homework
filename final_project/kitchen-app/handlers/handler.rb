require_relative '../clients/rmq'
require_relative '../models/dish'

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

    dish = Dish.find(data[:product_id])

    case message_name
    when 'PrepareDishCommand'
      if dish.quantity >= data[:quantity].to_i
        dish.quantity = dish.quantity - data[:quantity].to_i
        dish.save!

        @rmq.send_message(data, 'app.queue.order', 'DishPreparedEvent')
      else
        @rmq.send_message(data, 'app.queue.order', 'DishCanceledEvent')
      end
    when 'CancelDishCommand'
      dish.quantity = dish.quantity + data[:quantity].to_i
      dish.save!

      @rmq.send_message(data, 'app.queue.order', 'DishCanceledEvent')
    else
      puts "Unhandled message type: #{message_name}"
    end if dish.present?
  end
end