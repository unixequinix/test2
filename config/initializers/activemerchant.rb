ActiveMerchant::Billing::Base.mode = Rails.env.eql?("production") ? :production : :test
