require_relative '../models/transaction'

class Handler

  def handle_message(delivery_info, properties, payload)
    message_name = properties.headers['message_name']
    data = JSON.parse(payload, symbolize_names: true)

    puts "Received message: #{message_name}"
    puts "Routing Key: #{delivery_info.routing_key}"
    puts "Payload: #{data}"

    transaction = Transaction.find(data[:transaction_id])

    case message_name
    when 'FundsTransferredEvent'

      commit_outbox(data, 'TransferFundsCommand')
      transaction.update({billing_state: true})
      create_outbox(data, 'app.queue.kitchen', 'PrepareDishCommand')

    when 'FundsRevertedEvent'

      commit_outbox(data, 'RevertFundsCommand')
      commit_outbox(data, 'TransferFundsCommand')
      transaction.update({billing_state: false})
      Order.find(data[:order_id]).update({status: 'failed'})

    when 'DishPreparedEvent'

      commit_outbox(data, 'PrepareDishCommand')
      transaction.update({storage_state: true})
      create_outbox(data, 'app.queue.delivery', 'BookCourierCommand')

    when 'DishCanceledEvent'

      commit_outbox(data, 'PrepareDishCommand')
      commit_outbox(data, 'CancelDishCommand')
      transaction.update({storage_state: false})
      create_outbox(data, 'app.queue.billing', 'RevertFundsCommand')

    when 'CourierBookedEvent'

      commit_outbox(data, 'BookCourierCommand')
      transaction.update({delivery_state: true})
      if transaction.billing_state && transaction.storage_state && transaction.delivery_state
        Order.find(data[:order_id]).update({status: 'success'})
      end

    when 'CourierUnbookedEvent'

      commit_outbox(data, 'BookCourierCommand')
      commit_outbox(data, 'UnbookCourierCommand')
      transaction.update({delivery_state: false})
      create_outbox(data, 'app.queue.kitchen', 'CancelDishCommand')

    else
      puts "Unhandled message type: #{message_name}"
    end if transaction.present?
  end

  def create_outbox(data, queue, event_type)
    Outbox.create({
                    idempotency_key: data[:idempotency_key],
                    queue: queue,
                    event_type: event_type,
                    payload: data.to_json
                  })
  end

  def commit_outbox(data, event_type)
    outbox = Outbox.find_by(idempotency_key: data[:idempotency_key], event_type: event_type)
    outbox.update({committed: true}) if outbox.present?
  end
end