namespace :deploy do
  desc "Fill database with sample data"
  task secrets: :environment do
    %w[secrets database].each do |file|
      file_path = Rails.root.join("config", "#{file}.yml")
      system "scp -i #{ENV['GLOWNET_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_gspot/shared/config"
    end
  end
end