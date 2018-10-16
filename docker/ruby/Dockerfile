FROM ruby:2.1.5

RUN apt-get update -qq

RUN apt-get install -y \
  mysql-client \
  vim

# Defailt to /app directory
RUN mkdir /app
WORKDIR /app

# Install gems
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy in application's source
COPY . /app

ENTRYPOINT ["/app/docker-entry.sh"]

CMD ["unicorn", "--listen", "3000"]
