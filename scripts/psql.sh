#!/usr/bin/env bash

IMG='postgres:10.4-alpine'
NAME='slack_proxy3_postgres'

docker exec \
  -it \
  "$NAME" \
  psql -U postgres
