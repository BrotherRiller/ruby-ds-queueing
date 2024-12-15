require 'bunny'
require 'json'
require 'securerandom'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and connect to the 'orders' queue
channel = connection.create_channel
orders_queue = channel.queue('orders', durable: true)

# Predefined items
ITEMS = [
  { id: SecureRandom.uuid, name: 'USB-C Dongle', price: 14.99 },
  { id: SecureRandom.uuid, name: '8k Camera', price: 849.79 },
  { id: SecureRandom.uuid, name: 'Gaming Mouse', price: 49.99 },
  { id: SecureRandom.uuid, name: 'Elden Ring Moonlight Greatsword', price: 1000.00}
]

# Initialize order counter
order_counter = 0

puts "Choose mode: (1) Manual (2) Continuous"
mode = gets.chomp.to_i

if mode == 2
  puts "Continuous mode enabled. Press CTRL+C to stop..."
  loop do
    order_counter += 1 # Increment order counter

    # Randomly select items
    selected_items = ITEMS.sample(rand(1..4)).map do |item|
      item.merge(quantity: rand(1..5)) # Add random quantity
    end

    # Create the order
    order = {
      id: SecureRandom.uuid,
      createdAt: Time.now.to_i,
      items: selected_items,
      customer: {
        id: SecureRandom.uuid,
        name: 'Jane Doe',
        mail: 'jane@doe.com'
      },
      orderNumber: order_counter
    }

    # Publish the order to the orders queue
    orders_queue.publish(JSON.generate(order))
    puts " [#{order_counter}] Sent Order ID: #{order[:id]} with #{selected_items.size} items"

    # Random delay between messages
    sleep(rand(2..5))
  end
else
  puts "Manual mode enabled. Type 'exit' to quit."

  loop do
    puts "Enter item numbers; 1: USB-C Dongle, 2: 8k Camera, 3: Gaming Mouse, 4: Elden Ring Sword"
    input = gets.chomp
    break if input.downcase == 'exit'

    selected_items = input.split.map { |i| ITEMS[i.to_i - 1] }.map do |item|
      item.merge(quantity: 1) # Default quantity
    end

    order_counter += 1 # Increment order counter

    # Create the order
    order = {
      id: SecureRandom.uuid,
      createdAt: Time.now.to_i,
      items: selected_items,
      customer: {
        id: SecureRandom.uuid,
        name: 'Jane Doe',
        mail: 'jane@doe.com'
      },
      orderNumber: order_counter
    }

    # Publish the order to the orders queue
    orders_queue.publish(JSON.generate(order))
    puts " [#{order_counter}] Sent Order ID: #{order[:id]} with #{selected_items.size} items"
  end
end

# Close the connection
connection.close
