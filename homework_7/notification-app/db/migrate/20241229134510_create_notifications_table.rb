class CreateNotificationsTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:notifications)

    create_table :notifications do |t|
      t.integer :user_id, null: true
      t.string :notification, null: true

      t.timestamps null: false
    end
  end
end
