#!/bin/bash

fecha=$(date +%Y%m%d%H%M%S)
service nginx stop
service redis stop
service sidekiq stop
service passenger stop
find /home/deploy/current -type l -exec unlink {} \;
rm -rf /home/deploy/current/*
mkdir $fecha

