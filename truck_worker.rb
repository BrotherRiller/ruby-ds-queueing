require 'bunny'
require 'json'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and connect to the 'parcel_queue'
channel = connection.create_channel
parcel_queue = channel.queue('parcel_queue', durable: true)

puts 'Waiting for parcels from the "parcel_queue". Press CTRL+C to exit...'

# Subscribe to the parcel queue
parcel_queue.subscribe(block: true) do |_delivery_info, _properties, body|
  begin
    # Parse the incoming message
    message = JSON.parse(body)

    # Extract parcel details
    parcel_id = message['id']
    order_number = message['orderNumber']
    items = message['items']

    # Display parcel details
    puts " [x] Loading Parcel ##{order_number} (Parcel ID: #{parcel_id})"
    puts "     Items:"
    items.each do |item|
      puts "       - #{item['name']} (#{item['quantity']} x $#{item['price']})"
    end
    sleep(rand(2..5)) # Random delay to simulate loading

    puts " [x] Parcel ##{order_number} loaded onto truck\n\n"

  rescue JSON::ParserError => e
    puts " [!] Failed to process parcel: #{e.message}"
  end
end

# Close the connection when done
connection.close
