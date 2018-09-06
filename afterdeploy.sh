#!/bin/bash

mkdir -p /home/deploy/current
rm -f /home/deploy/current/beforedeploy.sh
rm -f /home/deploy/current/appspec.yml
rm -f /home/deploy/current/afterdeploy.sh
cd /home/deploy/current
ln -s /home/deploy/shared/log log


chmod -R 775 /home/deploy/current
chmod -R 775 /home/deploy/current

service nginx start
service redis start
service sidekiq start
service passenger start


