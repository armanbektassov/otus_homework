class CreateOrdersTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:orders)

    create_table :orders do |t|
      t.integer :user_id, null: true
      t.integer :product_id, null: true
      t.integer :quantity, null: true
      t.integer :hour, null: true
      t.string :status, null: true

      t.timestamps null: false
    end
  end
end
