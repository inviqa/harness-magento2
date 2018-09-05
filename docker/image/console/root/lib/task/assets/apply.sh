#!/bin/bash

function task_assets_apply()
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
        
        task "magento:configure"
    fi

    if [ -f "/app/tools/assets/development/files.tar.gz" ]; then
        run "tar -zxvf /app/tools/assets/development/files.tar.gz -C /app"
    fi
}
