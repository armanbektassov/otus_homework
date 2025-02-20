class CreateWalletsTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:wallets)

    create_table :wallets do |t|
      t.integer :user_id, null: true
      t.integer :amount_fractional, null: true

      t.timestamps null: false
    end
  end
end
