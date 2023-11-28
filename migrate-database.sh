#!/bin/sh
set -e

echo "start check if server.pid"
if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

echo "prepare"

echo "migrate"
bundle exec rake db:migrate
echo "migrate ok"
bundle exec rake assets:precompile

echo "start app"
bundle exec puma -C config/puma.rb
echo "start app ok"
echo "exec bundle exec $ @"
exec bundle exec "$@"
