#!/bin/bash

function task_assets_dump()
{
    if [ ! -d /app/tools/assets/development ]; then
        run "mkdir -p /app/tools/assets/development"
    fi

    run "mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} | gzip > /app/tools/assets/development/${DB_NAME}.sql.gz"
}
