require 'sinatra/activerecord'
require_relative '../clients/client'
require_relative '../clients/rmq'
require_relative '../models/transaction'

class TransactionService

  def initialize(order)
    @order = order
    @client = Client.new
    @rmq = Rmq.new
  end

  def process
    transaction = Transaction.create(order_id: @order.id)
    response = @client.get_product(@order.product_id)
    product = JSON.parse(response, {:symbolize_names => true})

    @rmq.send_message(
      {
        user_id: @order.user_id,
        order_id: @order.id,
        transaction_id: transaction.id,
        product_id: product[:id],
        quantity: @order.quantity,
        hour: @order.hour,
        amount_fractional: product[:amount_fractional].to_i
      },
      'app.queue.billing',
      'TransferFundsCommand'
    )
  end
end