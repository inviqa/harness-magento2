#!/bin/bash

function task_magento_install()
{
    task "mysql:available"

    # the magento installer will not work if the dpeloyment config is present so we remove and
    # restore it after installation.

    rm -f /app/app/etc/env.php
    rm -f /app/app/etc/config.php

    passthru "magento setup:install \
        --key=${MAGENTO_CRYPT_KEY} \
        \
        --backend-frontname=admin \
        --base-url=https://${APP_HOST}/ \
        \
        --admin-user=admin \
        --admin-password=admin123 \
        --admin-email=admin@localhost.local \
        --admin-firstname=First \
        --admin-lastname=Last \
        \
        --db-host=${DB_HOST} \
        --db-name=${DB_NAME} \
        --db-user=${DB_USER} \
        --db-password=${DB_PASS} \
        \
        --session-save=redis \
        --session-save-redis-host=redis \
        --session-save-redis-port=6379 \
        --session-save-redis-db=1 \
        \
        --cache-backend=redis \
        --cache-backend-redis-server=redis \
        --cache-backend-redis-port=6379 \
        --cache-backend-redis-db=2 \
        \
        --page-cache=redis \
        --page-cache-redis-server=redis \
        --page-cache-redis-port=6379 \
        --page-cache-redis-db=3"

    # magento doesn't respond with an exit code when it fails so we check
    # if the install succeeded or not here.
    if [ ! -f /app/app/etc/env.php ]; then
        (>&2 cat /tmp/my127ws-stdout.txt)
        (>&2 cat /tmp/my127ws-stderr.txt)
        exit 1
    fi

    rm -f /app/app/etc/env.php

    task "skeleton:apply"
    task "assets:dump"
}
