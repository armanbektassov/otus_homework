require_relative '../clients/rmq'
require_relative '../models/transaction'

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

    transaction = Transaction.find(data[:transaction_id])

    case message_name
    when 'FundsTransferredEvent'

      transaction.update({billing_state: true})
      @rmq.send_message(data, 'app.queue.storage', 'BookProductCommand')

    when 'FundsRevertedEvent'

      transaction.update({billing_state: false})
      Order.find(data[:order_id]).update({status: 'failed'})

    when 'ProductBookedEvent'

      transaction.update({storage_state: true})
      @rmq.send_message(data, 'app.queue.delivery', 'BookCourierCommand')

    when 'ProductUnbookedEvent'

      transaction.update({storage_state: false})
      @rmq.send_message(data, 'app.queue.billing', 'RevertFundsCommand')

    when 'CourierBookedEvent'

      transaction.update({delivery_state: true})
      if transaction.billing_state && transaction.storage_state && transaction.delivery_state
        Order.find(data[:order_id]).update({status: 'success'})
      end

    when 'CourierUnbookedEvent'

      transaction.update({delivery_state: false})
      @rmq.send_message(data, 'app.queue.storage', 'UnbookProductCommand')

    else
      puts "Unhandled message type: #{message_name}"
    end if transaction.present?
  end
end