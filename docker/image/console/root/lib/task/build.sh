#!/bin/bash

function task_build()
{
    task "skeleton:apply"

    task "build:backend"
    task "build:frontend"
}
