require_relative '../clients/rmq'
require_relative '../models/wallet'

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

    wallet = Wallet.find_by(user_id: data[:user_id])
    sum = data[:amount_fractional].to_i * data[:quantity].to_i

    case message_name
    when 'TransferFundsCommand'
      if wallet.amount_fractional.to_i >= sum
        wallet.amount_fractional = wallet.amount_fractional.to_i - sum
        wallet.save!

        @rmq.send_message(data, 'app.queue.order', 'FundsTransferredEvent')
      else
        @rmq.send_message(data, 'app.queue.order', 'FundsRevertedEvent')
      end
    when 'RevertFundsCommand'
        wallet.amount_fractional = wallet.amount_fractional.to_i + sum
        wallet.save!

        @rmq.send_message(data, 'app.queue.order', 'FundsRevertedEvent')
    else
      puts "Unhandled message type: #{message_name}"
    end if wallet.present?
  end
end