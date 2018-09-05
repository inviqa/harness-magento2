#!/bin/bash

function task_build()
{
    case "$1" in
        "pass-1")
            _build_pass_1
            ;;
        "pass-2")
            _build_pass_2
            ;;
    esac
}

_build_pass_1()
{
    task "skeleton:apply"
    task "composer:install"
    task "magento:tidy"
}

_build_pass_2()
{
    if [ "${APP_MODE}" = "production" ]; then
        run "bin/magento setup:di:compile"
        run "bin/magento setup:static-content:deploy"
    fi
}
