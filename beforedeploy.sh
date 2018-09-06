#!/bin/bash

service nginx stop
service redis stop
service sidekiq stop
service passenger stop
rm -rf /home/deploy/current/*

