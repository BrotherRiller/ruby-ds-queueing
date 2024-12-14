require 'bunny'
require 'json'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and connect to the 'notifications' queue
channel = connection.create_channel
queue = channel.queue('notifications', durable: true)

# Consume messages from the queue
puts 'Waiting for notifications from the "notifications" queue. Press CTRL+C to exit...'

queue.subscribe(block: true) do |_delivery_info, _properties, body|
  begin
    # Parse the JSON message
    message = JSON.parse(body)

    # Process the notification
    puts " [x] Received Notification ID: #{message['id']}"
    puts "     Type: #{message['type']}"
    puts "     Content: #{message['content']}"
    puts " [x] Notification Processed\n\n"

  rescue JSON::ParserError => e
    puts " [!] Failed to parse message: #{e.message}"
  end
end

# Close the connection (This won't be reached in blocking mode)
connection.close
