#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# DO_NOT_PREPARE=false
RUN_PREPARE=${DO_NOT_PREPARE:-false}

if [[ "$RUN_PREPARE" = "false" ]]
  then
    echo "DO_NOT_PREPARE is not set or is false, preparing.."
    bundle exec rake assets:precompile
    # bundle exec rake db:migrate
    # bundle exec rake db:seed || echo "db is already seeded"
fi

#source docker/.env

echo "Starting unicorn"
mkdir -p log
touch log/production.log

# echo $POSTGRES_HOST
exec bundle exec unicorn -E production -c config/unicorn.rb -p 8080
