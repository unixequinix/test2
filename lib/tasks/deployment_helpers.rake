namespace :deploy do
  desc "Upload keys into the server"
  task :secrets do
    %w[secrets database newrelic sidekiq].each do |file|
      file_path = Rails.root.join("config", "#{file}.yml")
      system "scp -i #{ENV['GSPOT_STAGING_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_web/shared/config"
    end
  end

  task :secrets_multiserver, [:server, :host] do |t, args|
    %w[secrets database newrelic sidekiq].each do |file|
      file_path = Rails.root.join("config/servers/#{args[:server]}", "#{file}.yml")
      system "scp -i #{ENV['GSPOT_STAGING_CERT']} #{file_path} ubuntu@#{args[:host]}:/home/ubuntu/glownet_web/shared/config"
    end
  end

  task :certs do
    %w[gd_bundle.crt glownet.crt glownet.key].each do |file|
      file_path = Rails.root.join("certs", "#{file}")
      system "scp -i #{ENV['GSPOT_STAGING_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_web/shared/certs"
    end
  end

  task :secrets_production do
    %w[secrets database newrelic sidekiq].each do |file|
      file_path = Rails.root.join("config", "#{file}.yml")
      system "scp -i #{ENV['GSPOT_PRODUCTION_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_web/shared/config"
    end
  end

  task :secrets_production_multiserver, [:server, :host] do |t, args|
    %w[secrets database newrelic sidekiq].each do |file|
      file_path = Rails.root.join("config/servers/#{args[:server]}", "#{file}.yml")
      system "scp -i #{ENV['GSPOT_PRODUCTION_CERT']} #{file_path} ubuntu@#{args[:host]}:/home/ubuntu/glownet_web/shared/config"
    end
  end

  task :certs_production do
    %w[gd_bundle.crt glownet.crt glownet.key].each do |file|
      file_path = Rails.root.join("certs", "#{file}")
      system "scp -i #{ENV['GSPOT_PRODUCTION_CERT']} #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_web/shared/certs"
    end
  end
end
