namespace :glownet do
  desc "Creates a basic admin access"
  task create_admin: :environment do
    admin = User.find_by(email: "developers@glownet.com")
    if admin
      admin.update!(password: "password", password_confirmation: "password")
      puts "- Admin password reseted"
    else
      User.create!(email: "developers@glownet.com", password: "password", password_confirmation: "password")
      puts "- Admin created successfuly"
    end
  end

  desc "Upload certifications to the specified server"
  task :upload_certs do
    %w[gd_bundle.crt glownet.crt glownet.key].each do |file|
      file_path = Rails.root.join("certs", "#{file}")
      system "scp #{file_path} ubuntu@#{Rails.application.secrets.host}:/home/ubuntu/glownet_web/shared/certs"
    end
  end
end
