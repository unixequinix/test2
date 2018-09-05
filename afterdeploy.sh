#!/bin/bash

rm -f /home/deploy/releases/$fecha/beforedeploy.sh
rm -f /home/deploy/releases/$fecha/appspec.yml
rm -f /home/deploy/releases/$fecha/afterdeploy.sh

ln -s /home/deploy/releases/$fecha current
ln -s /home/deploy/shared/log log


chmod -R 775 /home/deploy/releases/$fecha
chmod -R 775 /home/deploy/current

service nginx start
service redis start
service sidekiq start
service passenger start


