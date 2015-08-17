current_dir=`pwd`
script_dir=$current_dir/`dirname $0`

cd $script_dir
cd ..

echo 'Drop Database'
bin/rake RAILS_ENV=development db:drop
echo 'Create Database'
bin/rake RAILS_ENV=development db:create
echo 'Migrate'
bin/rake RAILS_ENV=development db:migrate
echo 'Populate'
bin/rake RAILS_ENV=development db:seed
bin/rake RAILS_ENV=development db:populate

echo 'Test Database config'
bin/rake RAILS_ENV=test db:drop
bin/rake RAILS_ENV=test db:create
bin/rake RAILS_ENV=test db:migrate

cd $current_dir

bundle exec annotate --exclude tests,fixtures
bundle exec erd --orientation=horizontal --title='GSPOT DB Diagram' --attributes=primary_keys,foreign_keys,inheritance,content
