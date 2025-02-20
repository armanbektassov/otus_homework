require 'sinatra/activerecord'

class Outbox < ActiveRecord::Base
  self.table_name = 'outbox'
  scope :pending_events, -> {
    where("processed_at IS NULL OR (committed = FALSE AND processed_at < NOW() - INTERVAL '5 minutes')")
      .order(:created_at)
      .limit(10)
  }
end