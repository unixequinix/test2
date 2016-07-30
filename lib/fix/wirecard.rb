require 'csv'

CSV.foreach("/home/ubuntu/glownet_web/current/lib/fix/wirecard.csv") do |row|
  order = Order.find_by(number: row[1].to_s)
  order&.payments&.first&.update(merchant_code: row[0].to_s)
end
