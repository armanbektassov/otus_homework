require_relative '../clients/rmq'
require_relative '../models/hour'

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

    hour = Hour.find_by(hour: data[:hour])

    case message_name
    when 'BookCourierCommand'
      if hour.busy
        @rmq.send_message(data, 'app.queue.order', 'CourierUnbookedEvent')
      else
        hour.update(busy: true)

        @rmq.send_message(data, 'app.queue.order', 'CourierBookedEvent')
      end
    when 'UnbookCourierCommand'
      hour.update(busy: false)

      @rmq.send_message(data, 'app.queue.order', 'CourierUnbookedEvent')
    else
      puts "Unhandled message type: #{message_name}"
    end if hour.present?
  end
end