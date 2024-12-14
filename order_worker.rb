require 'bunny'
require 'json'
require 'securerandom'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and connect to the 'orders' queue
channel = connection.create_channel
orders_queue = channel.queue('orders', durable: true)

# Declare the parcel queue
parcel_queue = channel.queue('parcel_queue', durable: true)

# Consume messages from the orders queue
puts 'Waiting for messages from the "orders" queue. Press CTRL+C to exit...'

orders_queue.subscribe(block: true) do |_delivery_info, _properties, body|
  begin
    # Parse the JSON message
    message = JSON.parse(body)
    
    # Simulate processing and creating a parcel
    puts " [x] Processing Order ID: #{message['id']}"
    sleep(rand(2..5)) # Random delay between 2 and 5 seconds
    parcel = {
      id: SecureRandom.uuid,
      orderId: message['id'],
      items: message['items'],
      customer: message['customer']
    }

    # Publish the parcel to the parcel_queue
    parcel_queue.publish(JSON.generate(parcel))
    puts " [x] Sent Parcel ID: #{parcel[:id]} to parcel_queue\n\n"

  rescue JSON::ParserError => e
    puts " [!] Failed to parse message: #{e.message}"
  end
end

# Close the connection (This won't be reached in blocking mode)
connection.close
