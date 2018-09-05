#!/bin/bash

function task_skeleton_apply()
{
    run "rsync --exclude='*.twig' --ignore-existing -a /home/build/skeleton/ /app/"
}
