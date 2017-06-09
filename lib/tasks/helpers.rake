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

  task touch_event: :environment do
    loop do
      event = Event.friendly.find 59
      order_ids = event.orders.completed.pluck(:id).sort_by{ rand }.slice(0, 100)
      customer_ids = event.customers.pluck(:id).sort_by{ rand }.slice(0, 100)
      gtag_ids = event.gtags.pluck(:id).sort_by{ rand }.slice(0, 100)

      event.orders.where(id: order_ids).update_all(updated_at: Time.now)
      event.customers.where(id: customer_ids).update_all(updated_at: Time.now)
      event.gtags.where(id: gtag_ids).update_all(updated_at: Time.now)
      puts "- Updated 100"
      sleep 30
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
