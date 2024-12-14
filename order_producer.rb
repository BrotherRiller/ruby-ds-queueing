require 'bunny'
require 'json'
require 'securerandom'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and connect to the 'orders' queue
channel = connection.create_channel
orders_queue = channel.queue('orders', durable: true)

puts "Choose mode: (1) Manual (2) Continuous"
mode = gets.chomp.to_i

if mode == 2
  puts "Continuous mode enabled. Press CTRL+C to stop..."
  loop do
    # Simulate creating a random order
    order = {
      id: SecureRandom.uuid,
      createdAt: Time.now.to_i,
      items: [
        { id: SecureRandom.uuid, name: 'USB-C Dongle', price: 14.99, quantity: 1 },
        { id: SecureRandom.uuid, name: '8k Camera', price: 849.79, quantity: 1 }
      ],
      customer: {
        id: SecureRandom.uuid,
        name: 'Jane Doe',
        mail: 'jane@doe.com'
      }
    }

    # Publish the order to the orders queue
    orders_queue.publish(JSON.generate(order))
    puts " [x] Sent: #{order}"
    
    # Random delay between messages
    sleep(rand(1..3))
  end
else
  puts "Manual mode enabled. Type order details. Type 'exit' to quit."
  loop do
    puts "Enter order details. Press Enter to send or type 'exit' to stop:"
    input = gets.chomp
    break if input.downcase == 'exit'

    order = {
      id: SecureRandom.uuid,
      createdAt: Time.now.to_i,
      items: [
        { id: SecureRandom.uuid, name: 'USB-C Dongle', price: 14.99, quantity: 1 },
        { id: SecureRandom.uuid, name: '8k Camera', price: 849.79, quantity: 1 }
      ],
      customer: {
        id: SecureRandom.uuid,
        name: 'Jane Doe',
        mail: 'jane@doe.com'
      }
    }

    # Publish the order to the orders queue
    orders_queue.publish(JSON.generate(order))
    puts " [x] Sent: #{order}"
  end
end

# Close the connection
connection.close
