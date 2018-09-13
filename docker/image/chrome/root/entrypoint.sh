#!/bin/bash

# we want application requests to go via traefik on the host system
if ! grep "$APP_HOST" /etc/hosts > /dev/null ; then
    DOCKER_INTERNAL_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
    echo -e "$DOCKER_INTERNAL_IP    $APP_HOST" | tee -a /etc/hosts > /dev/null
fi

/usr/bin/dumb-init -- /usr/bin/google-chrome-unstable \
  --no-sandbox \
  --disable-gpu \
  --headless \
  --disable-dev-shm-usage \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222 \
  --user-data-dir=/data \
  "$@"
