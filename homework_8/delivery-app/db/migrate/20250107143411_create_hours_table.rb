class CreateHoursTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:hours)

    create_table :hours do |t|
      t.integer :hour, null: false
      t.boolean :busy, default: false

      t.timestamps null: false
    end
  end
end
