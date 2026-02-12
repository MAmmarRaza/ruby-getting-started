#!/usr/bin/env bash

# Create the config directory for Postgres
mkdir -p "$DD_CONF_DIR/conf.d/postgres.d"

# Automatically parse Heroku's DATABASE_URL to configure the Agent
if [ -n "$DATABASE_URL" ]; then
  # This regex extracts user, password, host, port, and dbname from the URL
  POSTGREGEX='^postgres://([^:]+):([^@]+)@([^:]+):([^/]+)/(.*)$'
  if [[ $DATABASE_URL =~ $POSTGREGEX ]]; then
    cat <<EOF > "$DD_CONF_DIR/conf.d/postgres.d/conf.yaml"
init_config:
instances:
  - host: ${BASH_REMATCH[3]}
    port: ${BASH_REMATCH[4]}
    username: ${BASH_REMATCH[1]}
    password: ${BASH_REMATCH[2]}
    dbname: ${BASH_REMATCH[5]}
    ssl: True
    dbm: True  # THIS ENABLES DETAILED QUERY TRACES
EOF
  fi
fi