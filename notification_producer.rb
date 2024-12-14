require 'bunny'
require 'json'
require 'securerandom'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel and declare the 'notifications' queue
channel = connection.create_channel
queue = channel.queue('notifications', durable: true)

# Generate and send structured notification messages
puts 'Enter notification details. Type "exit" to quit.'

loop do
  # Example notification structure
  message = {
    id: SecureRandom.uuid,
    type: "INFO", # or "ERROR", "WARNING", etc.
    createdAt: Time.now.to_i,
    content: "System maintenance scheduled at midnight."
  }

  # Convert the message to JSON
  json_message = JSON.generate(message)

  # Publish the message
  queue.publish(json_message)
  puts " [x] Sent: #{json_message}"

  print '> Type "exit" to stop or press Enter to send another message: '
  input = gets.chomp
  break if input.downcase == 'exit'
end

# Close the connection
connection.close
