#!/usr/bin/env bash

if [ ! -f .flag-built ]; then

    passthru docker-compose -p "$NAMESPACE" down

    [[ "$HAS_ASSETS" = "yes" ]] && ws assets download

    if [ "$APP_BUILD" = "dynamic" ] && [ "${USE_DOCKER_SYNC}" = "yes" ]; then
        passthru docker-sync start
        passthru docker-sync stop
    fi

    if [ "$APP_BUILD" = "static" ]; then
        passthru docker-compose -p "$NAMESPACE" build --no-cache console
        passthru docker-compose -p "$NAMESPACE" up -d console
        passthru docker-compose -p "$NAMESPACE" exec -T -u build console app init
        [[ "${APP_MODE}" = "production" ]] && passthru docker-compose -p "$NAMESPACE" exec -T -u build console app build pass-2
        passthru docker commit "${NAMESPACE}_console_1" "${NAMESPACE}_console:latest"
        passthru docker-compose -p "$NAMESPACE" build --no-cache nginx php-fpm
        passthru docker-compose -p "$NAMESPACE" up -d
    else
        passthru docker-compose -p "$NAMESPACE" up -d --build
        passthru docker-compose -p "$NAMESPACE" exec -T -u build console app build pass-1
        passthru docker-compose -p "$NAMESPACE" exec -T -u build console app build pass-2
        passthru docker-compose -p "$NAMESPACE" exec -T -u build console app init
    fi

    touch .flag-built

else
    run docker-compose -p "$NAMESPACE" start
fi

if [ "$APP_BUILD" = "dynamic" ]; then
    [[ "$USE_DOCKER_SYNC" = "yes" ]] && passthru docker-sync start
fi
