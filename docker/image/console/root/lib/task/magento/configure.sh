#!/bin/bash

function task_magento_configure()
{
    run "magento config:set \"web/unsecure/base_url\"       \"https://${APP_HOST}/\""
    run "magento config:set \"web/secure/base_url\"         \"https://${APP_HOST}/\""
    run "magento config:set \"web/secure/use_in_frontend\"  \"1"\"
    run "magento config:set \"web/secure/use_in_adminhtml\" \"1"\"
    run "magento config:set \"web/seo/use_rewrites\"        \"1"\"
}
