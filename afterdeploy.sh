#!/bin/bash

mkdir -p /home/deploy/current
rm -f /home/deploy/current/beforedeploy.sh
rm -f /home/deploy/current/appspec.yml
rm -f /home/deploy/current/afterdeploy.sh
cd /home/deploy/current

service nginx restart


