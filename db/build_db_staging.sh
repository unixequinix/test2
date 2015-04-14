current_dir=`pwd`
script_dir=$current_dir/`dirname $0`

cd $script_dir
cd ..

bin/rake RAILS_ENV=staging db:drop
bin/rake RAILS_ENV=staging db:create
bin/rake RAILS_ENV=staging db:migrate
bin/rake RAILS_ENV=staging db:seed
bin/rake RAILS_ENV=staging db:populate

cd $current_dir
