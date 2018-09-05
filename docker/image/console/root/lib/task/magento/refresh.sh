#!/bin/bash

function task_magento_refresh()
{
    run "magento indexer:reindex"
    run "magento cache:clean"
}