class CreateTransactionsTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:transactions)

    create_table :transactions do |t|
      t.integer :order_id, null: true
      t.boolean :billing_state, default: false
      t.boolean :storage_state, default: false
      t.boolean :delivery_state, default: false

      t.timestamps null: false
    end
  end
end
