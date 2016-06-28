actions = ["onsite_topup", "onsite_refund"]
uids = ["000ce7011418", "000ce7012971", "000ce701298e", "000ce7012cc4", "000ce7012d0c", "000ce70132c2", "000ce70132c3", "000ce70132c6", "000ce70132da", "000ce701338f", "000ce7013419", "000ce70134d8", "000ce7013594", "000ce7013599", "000ce70135df", "000ce70135e2", "000ce70135e7", "000ce70135ed", "000ce70135ef", "000ce70135f6", "000ce7013667", "000ce7013669", "000ce70136b0", "000ce70136b5", "000ce7014481", "000ce7014485", "000ce7014486", "000ce70149ea", "000ce70149ed", "000ce7014afc", "000ce7014e9a", "000ce7015165", "000ce7015389", "000ce701788c", "000ce7017a66", "000ce7017a82", "000ce7017a84", "000ce7017abc", "000ce7017bd7", "000ce7017bda", "000ce7017bf4", "000ce7017bf7", "000ce7017bfa", "000ce7017c1a", "000ce7017c35", "000ce7017c50", "000ce7017c73", "000ce7017c8c", "000ce7017d89", "000ce7017de3", "000ce7017e5f", "000ce7017e81", "000ce7017ea3", "000ce70181a9", "000ce70181ac", "000ce70181cb", "000ce7018205", "000ce7018228", "000ce7018258", "000ce70182da", "000ce7018376", "000ce70183d5", "000ce70183d8", "000ce70183da", "000ce70183e5", "000ce70183f5", "000ce70183f6", "000ce70183f8", "000ce70183fa", "000ce70183fb", "000ce70185a6", "000ce70187dd", "000ce7018836", "000ce701883b", "000ce7018893", "000ce70188b1", "000ce70188c7", "000ce70188d1", "000ce70188dd", "000ce7018913", "000ce7018a21", "000ce7018b29", "000ce7018cd8", "000ce7018d29", "000ce7018d5f", "000ce7018ef3", "000ce7018f59", "000ce7018f7a", "000ce7019038", "000ce7019168", "000ce701927c", "000ce70192c9", "000ce7019318", "000ce70193a1", "000ce701945c", "000ce70196bc", "000ce70196c3", "000ce70197dd", "000ce7019886", "000ce701988b", "000ce7019bee", "020000000000", "1C994CEDAD7F", "38AA3CE3AF35", "50CCF8E2D023", "5C0A5B5B5367", "5C0A5B762949", "5C0A5B97D71F", "5C0A5BA2CF43", "5C0A5BDD8FA4", "5C0A5BFDB92D", "88308A78FC53", "88308ADD1AB7", "88329B81167F", "90187CC76E35"]
uids = ["5C0A5B97D71F".downcase]
actions.each do |action|
  puts action.upcase
  puts "=============================="

  uids.each do |uid|
    date_range = Time.parse("2016-06-18 11:00:00")...Time.parse("2016-06-18 20:00:00")
    params = {event_id: 2, device_uid: uid, status_code: 0, transaction_type: action}
    trans = MoneyTransaction.where(params)
    next if trans.map(&:price).sum.zero?
    stations = Station.where(id: trans.map(&:station_id).uniq)
    puts "#{Device.where(mac: uid).first.try(&:asset_tracker)} (#{uid}): #{trans.map(&:price).sum}"
    stations.each do |station|
      trans = MoneyTransaction.where(params).where(station: station)
      next if trans.map(&:price).sum.zero?
      puts "    #{station.name}"
      puts "         card: #{trans.where(payment_method: "card").map(&:price).sum}"
      puts "         cash: #{trans.where(payment_method: "cash").map(&:price).sum}"
    end
    puts
  end
end


# 1 - removes duplicate Gtags and profiles and moves all credits and transactions to appropiate profile
tags = Gtag.where(event_id: 2).select {|tag| not(tag.valid?) }
tags.group_by(&:tag_uid).each do |uid, tags|
  GtagMerger.perform_later(tags.map(&:id))
end.size
tags.select { |tag| tag.assigned_profile.nil? }.map(&:destroy)


# 2 - fills all gtag_counters for customer credits, and the correct time
no_credit = []
event = Event.find 2
profiles = event.profiles.includes(:credit_transactions, :customer_credits)
profiles.each do |profile|
  trans = profile.credit_transactions.select{|t| t.status_code == 0 }
  credits = profile.customer_credits
  trans.each do |t|
    credit = credits.select do |c|
      c.created_in_origin_at.strftime("%y-%m-%d %H:%M:%S.%L").split(" ").last == t.device_created_at.split(" ").last
    end.first
    if credit
      CreditUpdater.perform_later(credit.id, {gtag_counter: t.gtag_counter, created_in_origin_at: t.device_created_at})
    else
      no_credit << t
    end
  end
end.size


# 3 - adds gtag counter to online customer_credits
credits = CustomerCredit.includes(:profile).where(profile: Event.find(2).profiles, transaction_origin: "refund", gtag_counter: 0)
credits.group_by(&:profile).each do |profile, online|
  last_onsite_index = (profile.customer_credits - online).sort_by(&:gtag_counter).last.gtag_counter
  online.sort_by(&:created_in_origin_at).each_with_index do |c, i|
    CreditUpdater.perform_later(c.id, online_counter: i + 1, gtag_counter: last_onsite_index)
  end
end.size


# 3.5 - makes online customer_credits to have propperly calculated finals
profiles = Profile.where(id: CreditTransaction.where(event_id: 2, transaction_type: ["online_refund", "fee"]).pluck(:profile_id).uniq).includes(:customer_credits)
profiles.each do |p|
  all = p.customer_credits.reverse
  online = all.select{|c| c.online_counter != 0}
  offline = all - online
  last_balance = offline.last.final_balance
  last_r_balance = offline.last.final_refundable_balance
  online.each_with_index do |c, i|
    online_balance = last_balance + online.slice(0..i).map(&:amount).sum
    online_r_balance = last_r_balance + online.slice(0..i).map(&:refundable_amount).sum
    CreditUpdater.perform_later(c.id, final_balance: online_balance.to_f, final_refundable_balance: online_r_balance.to_f)
  end
end


# 4 - (final) resolves all inconsistencies. Reports and transactions not touched.
profiles = Event.find(2).profiles.includes(:customer_credits)
profiles.each do |p|
  credits = p.customer_credits
  last = credits.first
  next unless last

  new_amount = credits.map(&:amount).sum
  new_r_amount = credits.map(&:refundable_amount).sum

  next if new_amount == last.final_balance && new_r_amount == last.final_refundable_balance

  new_amount = last.final_balance - new_amount
  new_r_amount = last.final_refundable_balance - new_r_amount

  p.customer_credits.create!(amount: new_amount,
                             refundable_amount: new_r_amount,
                             final_balance: last.final_balance,
                             final_refundable_balance: last.final_refundable_balance,
                             payment_method: "credits",
                             created_in_origin_at: last.created_in_origin_at + 60,
                             transaction_origin: "script",
                             gtag_counter: last.gtag_counter,
                             online_counter: last.online_counter + 1)

end.size


#detects fraud from wb copy
@fraudsters = []
Event.find(2).profiles.select(:id).includes(:customer_credits, :credit_transactions, :access_transactions, :credential_transactions, :money_transactions, :order_transactions).find_in_batches.each do |profiles|
  profiles.each do |p|
    credits = p.customer_credits.reverse
    next if p.missing_transaction_counters.any?
    balance = 0
    credits.each_with_index do |credit, index|
      balance = balance + credit.amount
      @fraudsters << p if balance != credit.final_balance
    end
  end
end.size
puts @fraudsters.uniq.map(&:id)
