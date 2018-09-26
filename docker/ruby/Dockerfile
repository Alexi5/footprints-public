FROM ruby:2.1.5

RUN apt-get update -qq

# Defailt to /app directory
RUN mkdir /app
WORKDIR /app

# Install gems
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy in application's source
COPY . /app

# Remove any stale PID tmp files on build
RUN rm /app/tmp/pids/server.pid

# Apply migrations
RUN bin/rake db:migrate
