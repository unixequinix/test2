namespace :deploy do
  desc "Fill database with sample data"
  task secrets: :environment do
    %w[secrets database].each do |file|
      file_path = Rails.root.join("config", "#{file}.yml")
      system "scp -i #{ENV['GSPOT_STAGING_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_gspot/shared/config"
    end
  end

  task secrets_production: :environment do
    %w[secrets database].each do |file|
      file_path = Rails.root.join("config", "#{file}.yml")
      system "scp -i #{ENV['GSPOT_PRODUCTION_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_gspot/shared/config"
    end
  end

  task certs_production: :environment do
    %w[gd_bundle.crt glownet.crt glownet.key].each do |file|
      file_path = Rails.root.join("certs", "#{file}")
      system "scp -i #{ENV['GSPOT_PRODUCTION_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_gspot/shared/certs"
    end
  end
end