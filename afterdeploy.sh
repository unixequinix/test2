#!/bin/bash

mkdir -p /home/deploy/current
rm -f /home/deploy/current/beforedeploy.sh
rm -f /home/deploy/current/appspec.yml
rm -f /home/deploy/current/afterdeploy.sh
cd /home/deploy/current

rvm install 2.5.0
gem install bundler
sudo apt-get install libpq-dev
gem install pg -v '0.21.0'
service nginx restart


