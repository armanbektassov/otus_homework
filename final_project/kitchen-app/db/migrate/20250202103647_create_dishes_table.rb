class CreateDishesTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:dishes)

    create_table :dishes do |t|
      t.string :dish_name, null: true
      t.integer :amount_fractional, null: true
      t.integer :quantity, null: true

      t.timestamps null: false
    end
  end
end
