require 'bunny'

# Connect to RabbitMQ
connection = Bunny.new
connection.start

# Create a channel
channel = connection.create_channel

# Monitoring interval in seconds
MONITOR_INTERVAL = 5

# Define the queues to monitor
queues_to_monitor = ['orders']

# Tracking worker processing capacity (adjust as needed)
worker_capacity = {
  'orders' => 2 # Example: 2 workers are active for the 'orders' queue
}

puts "Monitoring queues: #{queues_to_monitor.join(', ')}"
puts "Press CTRL+C to stop..."

loop do
  puts "\n=== Monitoring Report ==="
  
  queues_to_monitor.each do |queue_name|
    # Get queue status
    queue = channel.queue(queue_name, passive: true)
    message_count = queue.message_count

    # Calculate if the queue is keeping up
    capacity = worker_capacity[queue_name]
    rate_of_incoming = message_count / MONITOR_INTERVAL.to_f # Approximation
    status = if capacity * MONITOR_INTERVAL >= message_count
               'Stable ✅'
             else
               'Overflowing ⚠️'
             end

    # Print report
    puts "Queue: #{queue_name}"
    puts "  - Current Messages: #{message_count}"
    puts "  - Workers: #{capacity}"
    puts "  - Status: #{status}"
  end

  sleep(MONITOR_INTERVAL)
end