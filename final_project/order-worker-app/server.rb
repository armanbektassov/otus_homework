require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require './clients/rmq'
require_relative './models/outbox'
set :database_file, 'config/database.yml'

class OutboxWorker < Sinatra::Base
  def self.start
    puts "Starting Outbox Worker..."
    loop do
      process_outbox
      sleep(1) # Slight delay to avoid a tight loop hammering the database
    end
  end

  def self.process_outbox
    Outbox.pending_events.each do |event|
      begin
        process_event(event)
        event.update(processed_at: Time.now)
        puts "Processed event #{event.id} with idempotent key: #{event.idempotency_key}"
      rescue => e
        puts "Failed to process event #{event.id}: #{e.message}"
      end
    end
  end

  def self.process_event(event)
    Rmq.new.send_message(
      event.payload,
      event.queue,
      event.event_type
    )
  end
end

OutboxWorker.start
