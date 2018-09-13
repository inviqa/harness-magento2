#!/usr/bin/env bash

[[ "$USE_DOCKER_SYNC" = "yes" ]] && run docker-sync stop
run docker-compose -p "$NAMESPACE" stop
