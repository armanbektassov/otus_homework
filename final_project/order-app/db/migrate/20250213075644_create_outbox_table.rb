class CreateOutboxTable < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.table_exists?(:outbox)

    create_table :outbox do |t|
      t.string :idempotency_key, null: false, unique: true
      t.string :queue, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false
      t.boolean :committed, default: false
      t.datetime :processed_at, null: true, default: nil
      t.timestamps null: false
    end
  end
end
