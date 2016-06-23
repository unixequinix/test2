# 1 - removes duplicate Gtags and profiles and moves all credits and transactions to appropiate profile
tags = Gtag.where(event_id: 2).select {|tag| not(tag.valid?) }
tags.group_by(&:tag_uid).each do |uid, tags|
  GtagMerger.perform_later(tags.map(&:id))
end.size
tags.group_by(&:tag_uid).size
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



#detects fraud from wb copy
@fraudsters = []
event.profiles.select(:id).includes(:customer_credits, :credit_transactions, :access_transactions, :credential_transactions, :money_transactions, :order_transactions).each do |p|
  credits = p.customer_credits
  next if p.missin_transaction_counters.any?
  balance = 0
  credits.each_with_index do |credit, index|
    new_balance = balance + credit.
        end
  end
