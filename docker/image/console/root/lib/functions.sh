#!/bin/bash

app.welcome()
{
    echo ""
    echo "Welcome!"
    echo "--------"
    echo "URL: https://${APP_HOST}"
    echo "Admin: /admin"
    echo "  Username: admin"
    echo "  Password: admin123"
    echo ""
}

assets.dump()
{
    if [ ! -d /app/tools/assets/development ]; then
        run "mkdir -p /app/tools/assets/development"
    fi

    run "mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} | gzip > /app/tools/assets/development/${DB_NAME}.sql.gz"
}

assets.apply()
{
    SQL="SELECT IF (COUNT(*) = 0, 'no', 'yes') FROM information_schema.tables WHERE table_schema = '$DB_NAME';"
    IS_DATABASE_APPLIED="$(mysql -ss -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "$SQL")"

    if [ "$IS_DATABASE_APPLIED" = "no" ]; then

        if [ -f "/app/tools/assets/development/${DB_NAME}.sql.gz" ]; then
            run "zcat /app/tools/assets/development/${DB_NAME}.sql.gz | mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME"
        else
            magento.install
        fi

        run magento setup:upgrade
        magento.configure
    fi
}

composer.install()
{
    if [ "$APP_MODE" = "production" ]; then
        passthru "composer install --no-interaction --optimize-autoloader"
    else
        passthru "composer install --no-interaction"
    fi
}

magento.configure()
{
    run "magento config:set \"web/unsecure/base_url\"       \"https://${APP_HOST}/\""
    run "magento config:set \"web/secure/base_url\"         \"https://${APP_HOST}/\""
    run "magento config:set \"web/secure/use_in_frontend\"  \"1"\"
    run "magento config:set \"web/secure/use_in_adminhtml\" \"1"\"
    run "magento config:set \"web/seo/use_rewrites\"        \"1"\"
}

magento.install()
{
    mysql.available

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

    skeleton.apply
    assets.dump
}

magento.refresh()
{
    run "magento indexer:reindex"
    run "magento cache:clean"
}

magento.tidy()
{
    rm -rf /app/.github
    rm -rf /app/phpserver

    rm -f /app/.htaccess
    rm -f /app/.htaccess.sample
    rm -f /app/.php_cs.dist
    rm -f /app/.travis.yml
    rm -f /app/.user.ini
    rm -f /app/auth.json.sample
    rm -f /app/CHANGELOG.md
    rm -f /app/COPYING.txt
    rm -f /app/grunt-config.json.sample
    rm -f /app/Gruntfile.js.sample
    rm -f /app/index.php
    rm -f /app/LICENSE_AFL.txt
    rm -f /app/LICENSE.txt
    rm -f /app/LICENSE_EE.txt
    rm -f /app/nginx.conf.sample
    rm -f /app/package.json.sample
    rm -f /app/php.ini.sample
    rm -f /app/README_EE.md
}

mysql.available()
{
    local counter=0

    while [ ! "$(mysqladmin -h $DB_HOST ping 2> /dev/null)" ]; do
        
        if (( counter > 30 )); then
            (>&2 echo "timeout while waiting on mysql to become available")
            exit 1
        fi

        sleep 1
        ((counter++))
    done
}

skeleton.apply()
{
    run "rsync --exclude='*.twig' --ignore-existing -a /home/build/skeleton/ /app/"
}
