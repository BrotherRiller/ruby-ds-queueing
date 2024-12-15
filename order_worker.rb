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

puts 'Waiting for messages from the "orders" queue. Press CTRL+C to exit...'

# Subscribe to the orders queue
orders_queue.subscribe(block: true) do |_delivery_info, _properties, body|
  begin
    # Parse the incoming message
    message = JSON.parse(body)

    # Extract order details
    order_id = message['id']
    order_number = message['orderNumber']
    items = message['items']

    # Display order details
    puts " [x] Processing Order ##{order_number} (Order ID: #{order_id})"
    puts "     Items:"
    items.each do |item|
      puts "       - #{item['name']} (#{item['quantity']} x $#{item['price']})"
    end
    sleep(rand(2..5)) # Random delay to simulate processing

    # Create the parcel to send to the next queue
    parcel = {
      id: SecureRandom.uuid,
      orderId: order_id,
      items: items,
      customer: message['customer'],
      orderNumber: order_number
    }

    # Publish the parcel to the parcel queue
    parcel_queue.publish(JSON.generate(parcel))
    puts " [x] Sent Parcel ##{order_number} to parcel_queue\n\n"

  rescue JSON::ParserError => e
    puts " [!] Failed to process message: #{e.message}"
  end
end

# Close the connection when done
connection.close
