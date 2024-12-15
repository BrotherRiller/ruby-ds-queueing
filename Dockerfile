# Use Ruby as the base image
FROM ruby:3.3

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock first
COPY Gemfile Gemfile.lock ./

# Install required gems
RUN gem install bundler && bundle install

# Copy the application files
COPY . .

# Expose RabbitMQ port (if needed for debugging)
EXPOSE 5672

# Set the default command
CMD ["ruby", "order_producer.rb"]