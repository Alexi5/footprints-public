#!/bin/sh
set -e

bundle install --without deploy production

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

exec bundle exec "$@"
