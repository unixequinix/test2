imeis = ["352701060340178", "352701060329965", "352701060329940", "352701060329981", "352701060251466", "352701060303523", "352701060330856", "352701060339626", "352701060330005", "352701060336481"]
event = Event.find(8)
CreditTransaction.where(status_code: 0, event: event, device_uid: imeis).where("device_created_at < ?", Date.new(2016, 1, 1)).group_by(&:device_uid).each do |uid, ts|
  puts uid
  ts.sort_by(&:device_created_at).each do |t|
    puts "     " + t.device_created_at
  end
end.size

event = Event.find(8)
profiles = event.profiles.select do |profile|
  creds = profile.customer_credits.order(created_in_origin_at: :desc)
  last = creds.first
  amount_sum = creds.map(&:amount).sum
  refundable_sum = creds.map(&:refundable_amount).sum

  last && (last.final_balance != amount_sum || last.final_refundable_balance != refundable_sum)
end


event = Event.find(8)
profiles = CreditTransaction.where(event: event, status_code: 2).map{|t| Gtag.find_by_tag_uid(t.customer_tag_uid).assigned_profile }.uniq
profiles.each do |profile|
  credits = profile.customer_credits
  last = credits.last
  amount = credits.sum(:amount)
  r_amount = credits.sum(:refundable_amount)

  next unless last
  next if (amount > 0) || (r_amount > 0)

  created_at = last.created_at + 300

  credit = profile.customer_credits.create!(amount: amount * -1, refundable_amount: r_amount * -1, final_balance: 0, final_refundable_balance: 0, payment_method: "cash", created_in_origin_at: (last.created_in_origin_at + 300), transaction_origin: "device")
  credit.update! created_at: created_at
end.size
profiles.each do |profile|
  credits = profile.customer_credits
  last = credits.last
  amount = credits.sum(:amount)
  r_amount = credits.sum(:refundable_amount)

  next unless last
  next if (amount < 0) || (r_amount < 0)

  last.final_balance = amount
  last.final_refundable_balance = r_amount
  last.save!
end.size

ds = {
  352701060336481 => 6.years + 4.months + 13.days + 18.hours,
  352701060329940 => 6.years + 4.months + 13.days + 19.hours + 50.minutes,
  352701060330856 => 6.years + 4.months + 14.days + 1.hours + 22.minutes + 50.seconds,
  352701060303523 => 6.years + 4.months + 14.days + 1.hours + 5.minutes,
  352701060339626 => 6.years + 4.months + 14.days + 2.hours,
  352701060329965 => 6.years + 4.months + 13.days + 19.hours + 45.minutes,
  352701060340178 => 6.years + 4.months + 13.days + 18.hours + 10.minutes,
  352701060329981 => 6.years + 4.months + 13.days + 18.hours + 23.minutes,
  352701060330005 => 6.years + 4.months + 13.days + 22.hours + 40.minutes,
  352701060251466 => 6.years + 4.months + 13.days + 23.hours
}

event = Event.find(8)
ds.each do |uid, diff|
  credit_trans = CreditTransaction.where(device_uid: uid, status_code: 0, event: event).where("device_created_at < ?", Date.new(2016, 1, 1))
  credits = CustomerCredit.where(profile_id: credit_trans.map(&:profile_id).uniq.compact).where("created_in_origin_at < ?", Date.new(2016, 1, 1))
  credits.each do |c|
    t = credit_trans.where(profile: c.profile, credits: c.amount, credits_refundable: c.refundable_amount, final_balance: c.final_balance, final_refundable_balance: c.final_refundable_balance).first
    next unless t
    new_t = c.created_in_origin_at + diff
    c.update! created_in_origin_at: new_t
    t.update! device_created_at: new_t
  end
end







def delete_duplicates(arr)
  ActiveRecord::Base.transaction do
    arr.values.each do |duplicates|
     first_one = duplicates.shift
     if first_one.respond_to? :really_delete
       duplicates.each(&:really_delete)
     else
       duplicates.each(&:destroy)
     end
    end.size
  end
end



delete_duplicates CreditTransaction.all.group_by{|model| [model.event_id, model.device_uid, model.device_db_index]}
delete_duplicates MoneyTransaction.all.group_by{|model| [model.event_id, model.device_uid, model.device_db_index]}
delete_duplicates CredentialTransaction.all.group_by{|model| [model.event_id, model.device_uid, model.device_db_index]}
delete_duplicates OrderTransaction.all.group_by{|model| [model.event_id, model.device_uid, model.device_db_index,]}
delete_duplicates AccessTransaction.all.group_by{|model| [model.event_id, model.device_uid, model.device_db_index]}


event = Event.find(4)
delete_duplicates CustomerCredit.where(customer_event_profile: event.profiles ).group_by{ |model| [model.created_in_origin_at, model.amount, model.refundable_amount]}


#====   Check db indexes
missing = {}
CreditTransaction.where(event_id: 4).group_by(&:device_uid).each do |uid, transactions|
  indexes = transactions.map(&:device_db_index).sort
  all_indexes = (1..indexes.last).to_a
  subset = all_indexes - indexes
  next if subset.empty?
  missing[uid] = subset
end.size
missing.keys


trans = CreditTransaction.where(event_id: 4).group_by{|model| [model.device_uid,model.device_db_index,model.device_created_at]}.select {|atts, trans| trans.size > 1}

def update_time(t, h = 2)
  time = Time.parse(t.device_created_at) - h.hours
  result = time.strftime("%Y-%m-%dT%T")
  t.update!(device_created_at: result)
end

CreditTransaction.where(event_id: 4).each { |t| update_time(t) }.size
MoneyTransaction.where(event_id: 4).each { |t| update_time(t) }.size
CredentialTransaction.where(event_id: 4).each { |t| update_time(t) }.size
OrderTransaction.where(event_id: 4).each { |t| update_time(t) }.size
AccessTransaction.where(event_id: 4).each { |t| update_time(t) }.size