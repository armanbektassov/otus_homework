class CreateOrdersTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:orders)

    create_table :orders do |t|
      t.integer :user_id, null: true
      t.string :order_name, null: true
      t.integer :amount_fractional, null: true

      t.timestamps null: false
    end
  end
end
