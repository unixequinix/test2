require 'csv'
require 'active_record'

CSV.foreach("/Users/agonzaleznu/Workspace/glownet_web/lib/fix/wirecard.csv") do |row|
  puts row[0]
  puts row[1]
  order = Order.find_by(number: row[0])
  order.payment.update!(merchant_code: row[1])
end
