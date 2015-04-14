current_dir=`pwd`
script_dir=$current_dir/`dirname $0`

cd $script_dir
cd ..

bin/rake RAILS_ENV=production db:drop
bin/rake RAILS_ENV=production db:create
bin/rake RAILS_ENV=production db:migrate
bin/rake RAILS_ENV=production db:seed

cd $current_dir
