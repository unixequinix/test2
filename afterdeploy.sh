#!/bin/bash

mkdir -p /home/deploy/current
ln -s /home/deploy/shared/config/application.yml /home/deploy/current/config/application.yml
/home/deploy/.rvm/bin/rvm 2.5.1 do bundle install --path /home/deploy/shared/bundle --without development test --deployment --quiet
rm -f /home/deploy/current/beforedeploy.sh
rm -f /home/deploy/current/appspec.yml
rm -f /home/deploy/current/afterdeploy.sh
cd /home/deploy/current

service nginx restart


