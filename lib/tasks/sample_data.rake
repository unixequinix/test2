namespace :db do

  desc "Fill database with sample data"
  task populate: :environment do
    Faker::Config.locale = :es
    puts "--------------------------------------------------------------------------------"
    puts "Creating fake data"
    puts "--------------------------------------------------------------------------------"
  end

end