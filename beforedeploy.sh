#!/bin/bash

service nginx stop
service redis-server stop
service sidekiq stop
rm -rf /home/deploy/current

