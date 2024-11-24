class CreateUsersTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:users)

    create_table :users do |t|
      t.string :username, null: true
      t.string :firstname, null: true
      t.string :lastname, null: true

      t.timestamps null: false
    end
  end
end
