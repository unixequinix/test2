event = Event.find 6

CreditTransaction.where(event: event).group_by(&:device_uid).each do |uid, ts|
  wrong = ts.select{|t| t.device_created_at.to_date < Date.new(2016, 5, 19) || t.device_created_at.to_date > Date.new(2016, 5, 23)}
  next unless wrong.any?
  puts uid
  wrong.each do |t|
    puts "     " + t.device_created_at + "  ->  " + t.profile_id.to_s
  end
end.size



# fixes time issues
ds = {
 352701060340061 => 6.years + 4.months + 19.days + 22.hours + 34.minutes,
 352701060413900 => - 1.month + 6.hours + 11.minutes,
 352701060337901 => 6.years + 4.months + 21.days + 15.hours + 49.minutes,
 352701060312755 => 6.years + 4.months + 21.days + 22.hours + 20.minutes

}
event = Event.find(6)
ds.each do |uid, diff|
 credit_trans = CreditTransaction.where(device_uid: uid, status_code: 0, event: event).where("device_created_at < ? OR device_created_at > ?", Date.new(2016, 1, 1), Date.new(2016, 5, 24))
 credits = CustomerCredit.where(profile_id: credit_trans.map(&:profile_id).uniq.compact).where("created_in_origin_at < ? OR created_in_origin_at > ?", Date.new(2016, 1, 1), Date.new(2016, 5, 24))
 credits.each do |c|
   t = credit_trans.where(profile: c.profile, credits: c.amount, credits_refundable: c.refundable_amount, final_balance: c.final_balance, final_refundable_balance: c.final_refundable_balance).first
   next unless t
   new_t = c.created_in_origin_at + diff
   c.update! created_in_origin_at: new_t
   t.update! device_created_at: new_t
 end
end


# Removes decimal problem
def custom_round(amount)
  amount.to_f.round(1)
end
CreditTransaction.where(event_id: 6).each do |ct|
  ct.credits = custom_round(ct.credits)
  ct.credits_refundable = custom_round(ct.credits_refundable)
  ct.final_balance = custom_round(ct.final_balance)
  ct.final_refundable_balance = custom_round(ct.final_refundable_balance)
  ct.save! if ct.changed?
end.size


# removes customer credits
event = Event.find 6
CustomerCredit.where(profile_id: event.profiles.pluck(:id)).delete_all



# fixes transaction issues STATUS_CODE: 2
trans_id = [38349, 22004, 22197, 22204, 22790, 22796, 22895, 22903, 23174, 23199, 23435, 23724, 24256, 24303, 24310, 24453, 24578, 24924, 25128, 25175, 25313, 25707, 25758, 25851, 25935, 26328, 26459, 26932, 27503, 27516, 27715, 27722, 27777, 27886, 27967, 28411, 28465, 28637, 28661, 28803, 28807, 29164, 29361, 29661, 29771, 30003, 30013, 31112, 32134, 32826, 33003, 33106, 33120, 33743, 33750, 34581, 34637, 35470, 35569, 37090, 37097, 37100, 37161, 37192, 37258, 37299, 37383, 37615, 37858, 37861, 37862, 37996, 37997, 38066, 38470, 38860, 38948, 38992, 39487, 39773, 39813, 40247, 41332, 41415, 41518, 41798, 41983, 42018, 42379, 42901, 42930, 42949, 43139, 43416, 43417, 43418, 43436, 43792, 43872, 44849, 45938, 46105, 46811, 46901, 46912, 46921, 47090, 47207, 47513, 47748, 48204, 48232, 48279, 48679, 48741, 48923, 49179, 49340, 50185, 50225, 50307, 50308, 50746, 51322, 51340, 52286, 52362, 52583, 52594, 52642, 52704, 52775, 53239, 53481, 53575, 53918, 54120, 54289, 54445, 54709, 54899, 54919, 54958, 55183, 55269, 55485, 55488, 55490, 55594, 56781, 56839]
status_9 = []
status_10 = []
CreditTransaction.where(event: event, id: trans_id).each do |t|
  new_code = t.status_code.zero? ? 2 : 0
  t.update! status_code: new_code
  status_9 << t if new_code == 2
  status_10 << t if new_code == 0
end.size

CreditTransaction.where(event: event, transaction_type: "refund", status_code: 2).where.not(id: trans_id).each do |t|
  t.update! status_code: 0
  status_10 << t
end.size

# creates custoemr credits again form transactions
def credit_from_transaction(t, gtags)
  atts = t.attributes.symbolize_keys
  atts.delete(:id)
  atts[:profile_id] = t.profile_id || gtags.find_by_tag_uid(t.customer_tag_uid).assigned_profile.id
  credit_atts = Operations::Base.new.column_attributes(CustomerCredit, atts)

  credit_atts.merge!(refundable_amount: atts[:credits_refundable],
                     amount: atts[:credits],
                     payment_method: "credits",
                     created_in_origin_at: atts[:device_created_at])

  CustomerCredit.new(credit_atts)
end


event = Event.find 6
gtags = event.gtags
credits = []
CreditTransaction.where(event: event, status_code: 0, transaction_type: Operations::Credit::BalanceUpdater::TRIGGERS).each do |t|
  credits << credit_from_transaction(t, gtags)
end.size
CreditTransaction.where(event: event, status_code: 0, transaction_type: "record_credit", station_id: 91).each do |t|
  credits << credit_from_transaction(t, gtags)
end.size
# return 1 credit for card users who paid
CreditTransaction.where(event: event, status_code: 0, transaction_type: "sale", station_id: 112).each do |t|
  profile = Profile.find(t.profile_id) || gtags.find_by_tag_uid(t.customer_tag_uid).assigned_profile
  creds = profile.customer_credits

  params = {
            refundable_amount: t.credits_refundable * -1.0,
            amount: t.credits * -1.0,
            final_balance: creds.sum(:amount),
            final_refundable_balance: creds.sum(:refundable_amount),
            payment_method: "credits",
            created_in_origin_at: Time.zone.now,
            profile: profile,
            credit_value: t.credit_value,
            transaction_origin: 'portal'
          }

  credits << CustomerCredit.new(params)
end
CustomerCredit.import(credits).size

status_9.each {|t| t.update! status_code: 9 }
status_10.each {|t| t.update! status_code: 10 }




# fixes negative balances with new transaction and credit
event = Event.find(6)
station = Station.find_or_create_by!(event: event, name: "Balance Corrections", station_type: StationType.find_by(name: "top_up_refund"))
profiles = event.profiles.includes(:customer_credits).select do |p|p.customer_credits
  p.customer_credits.map(&:amount).sum < 0
end
profiles.each_with_index do |p, index|
  amount = p.customer_credits.map(&:amount).sum * -1.0
  r_amount = p.customer_credits.map(&:refundable_amount).sum * -1.0
  t = CreditTransaction.create!(event: event,
                                transaction_origin: "script",
                                transaction_category: "credit",
                                transaction_type: "topup",
                                customer_tag_uid: p.active_gtag_assignment.credentiable.tag_uid,
                                station: station,
                                device_uid: "portal",
                                device_db_index: index + 1,
                                device_created_at: Time.zone.now + index,
                                credits: amount,
                                credits_refundable: r_amount,
                                credit_value: 1,
                                final_balance: 0,
                                final_refundable_balance: 0,
                                profile: p,
                                status_code: 0)
  credit_from_transaction(t, gtags).save!
end

# removes credit inconsistency form profile
event = Event.find(6)
credits2 = []
event.profiles.each do |p|
  credits = p.customer_credits
  last = credits.sort_by(&:created_in_origin_at).last
  next unless last

  sum_amount = credits.sum(:amount)
  sum_r_amount = credits.sum(:refundable_amount)

  next if sum_amount == last.final_balance && sum_r_amount == last.final_refundable_balance

  credits2 << CustomerCredit.new(amount: 0,
                                 refundable_amount: 0,
                                 final_balance: sum_amount,
                                 final_refundable_balance: sum_r_amount,
                                 payment_method: "credits",
                                 created_in_origin_at: last.created_in_origin_at + 60,
                                 transaction_origin: "script",
                                 profile: p)

end.size
CustomerCredit.import(credits2).size



# fixes weird woman issue with wrong checkin woman
p = Profile.find 4981
event = Event.find(6)
station = Station.find_by(event: event, name: "Customer Service Topup")
index = CreditTransaction.where(transaction_origin: "script", transaction_category: "credit", transaction_type: "topup", station: station).count
t = CreditTransaction.create!(event: event,
                              transaction_origin: "script",
                              transaction_category: "credit",
                              transaction_type: "topup",
                              customer_tag_uid: p.active_gtag_assignment.credentiable.tag_uid,
                              station_id: station.id,
                              device_uid: "portal",
                              device_db_index: index + 1,
                              device_created_at: (Time.zone.now + index).strftime("%Y-%m-%d %T.%L"),
                              credits: 35.5,
                              credits_refundable: 35.5,
                              credit_value: 1,
                              final_balance: 40,
                              final_refundable_balance: 40,
                              profile: p,
                              status_code: 0)
credit_from_transaction(t, [p.active_gtag_assignment.credentiable]).save!



# adds transaction for pre-event topups
station = Station.find(91)
event = Event.find(6)
CreditTransaction.where(event: event, status_code: 0, transaction_type: "record_credit", station: station).each_with_index do |t, index|
  p = t.profile || event.gtags.find_by_tag_uid(t.customer_tag_uid).assigned_profile
  CreditTransaction.create!(event: event,
                            transaction_origin: "script",
                            transaction_category: "credit",
                            transaction_type: "online_topup",
                            customer_tag_uid: p.active_gtag_assignment.credentiable.tag_uid,
                            station: station,
                            device_uid: "portal",
                            device_db_index: index + 1,
                            device_created_at: (Time.zone.now - 5.days - 5.hours).strftime("%Y-%m-%d %T.%L"),
                            credits: t.credits,
                            credits_refundable: t.credits_refundable,
                            credit_value: 1,
                            final_balance: t.final_balance,
                            final_refundable_balance: t.final_refundable_balance,
                            profile: p,
                            status_code: 0)
end



CreditTransaction.where(event_id: 6).select {|t| t.device_created_at.include? "+0200" }.each do |t|
  t.update device_created_at: t.device_created_at.gsub(" +0200", ".000")
end

t = CreditTransaction.find(56827)
t.update!(device_created_at: t.device_created_at.gsub("-06-", "-05-"))

t = CreditTransaction.find(29427)
t.update!(device_created_at: "2016-05-20 23:42:41.000")
CustomerCredit.find(89823).update! created_in_origin_at: t.device_created_at



items = {"4" => 30, "5" => 44, "6" => 64 }
event = Event.find 6
MoneyTransaction.where(event: 6, created_at: (Date.today - 40.days)..(Time.zone.now - (6.days + 3.hours))).each do |t|
  amount = items[t.catalogable_id.to_s]
  r_amount = amount == 30 ? amount : amount - 4

  customert_tag_uid = t.profile&.active_gtag_assignment&.credentiable&.tag_uid

  CreditTransaction.create!(event_id: 6,
                            transaction_origin: "customer_portal",
                            transaction_category: "credit",
                            transaction_type: "online_topup",
                            customer_tag_uid: customert_tag_uid,
                            station_id: t.station_id,
                            device_uid: t.device_uid,
                            device_db_index: t.device_db_index,
                            device_created_at: t.created_at + 60.seconds,
                            credits: amount,
                            credits_refundable: r_amount,
                            credit_value: 1,
                            final_balance: amount,
                            final_refundable_balance: r_amount,
                            profile_id: t.profile_id,
                            status_code: 0)
end