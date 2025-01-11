class CreateProductsTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:products)

    create_table :products do |t|
      t.string :product_name, null: true
      t.integer :amount_fractional, null: true
      t.integer :quantity, null: true

      t.timestamps null: false
    end
  end
end
