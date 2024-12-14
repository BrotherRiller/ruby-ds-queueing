require 'bunny'
require 'json'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and connect to the 'parcel_queue'
channel = connection.create_channel
parcel_queue = channel.queue('parcel_queue', durable: true)

# Consume messages from the parcel_queue
puts 'Waiting for parcels from the "parcel_queue". Press CTRL+C to exit...'

parcel_queue.subscribe(block: true) do |_delivery_info, _properties, body|
  begin
    # Parse the JSON message
    parcel = JSON.parse(body)

    # Simulate loading the parcel
    puts " [x] Loading Parcel ID: #{parcel['id']} for Order ID: #{parcel['orderId']}"
    puts "     Customer: #{parcel['customer']['name']} <#{parcel['customer']['mail']}>"
    sleep(rand(2..5)) # Simulate loading time
    puts " [x] Parcel Loaded\n\n"

  rescue JSON::ParserError => e
    puts " [!] Failed to parse message: #{e.message}"
  end
end

# Close the connection (This won't be reached in blocking mode)
connection.close