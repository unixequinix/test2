# SOlventa tema de las horas mal puestas
ds = {
 352701060336481 => 6.years + 4.months + 13.days + 18.hours,
 352701060329940 => 6.years + 4.months + 13.days + 19.hours + 56.minutes,
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

# solventa tema de las transacciones ocn status code 2
event = Event.find(8)
transactions = CreditTransaction.where(event: event, status_code: 2)
transactions.each do |transaction|
  profile = Gtag.find_by_tag_uid(transaction.customer_tag_uid).assigned_profile
  credits = profile.customer_credits
  last = credits.sort_by(&:created_in_origin_at).last
  amount = credits.sum(:amount)
  r_amount = credits.sum(:refundable_amount)

  next unless last
  next if amount == last.final_balance && r_amount = last.final_refundable_balance
  if transaction.credits > 0
    credit = profile.customer_credits.create!(amount: transaction.credits,
                                              refundable_amount: transaction.credits_refundable,
                                              final_balance: transaction.credits,
                                              final_refundable_balance: transaction.credits_refundable,
                                              payment_method: "credits",
                                              created_in_origin_at: transaction.device_created_at,
                                              transaction_origin: "script")
    credit.update! created_at: transaction.device_created_at
  else
    credit = profile.customer_credits.create!(amount: 0,
                                              refundable_amount: 0,
                                              final_balance: last.final_balance + (transaction.credits * -1.00),
                                              final_refundable_balance: last.final_refundable_balance + (transaction.credits_refundable * -1.00),
                                              payment_method: "credits",
                                              created_in_origin_at: last.created_in_origin_at + 60,
                                              transaction_origin: "script")
    credit.update! created_at: last.created_in_origin_at + 60
  end
end.size

# solventa inconsistencias. no afecta al refundable balance ni a los reports
event = Event.find(8)
event.profiles.each do |p|
  credits = p.customer_credits
  last = credits.sort_by(&:created_in_origin_at).last
  next unless last

  new_amount = credits.sum(:amount)
  new_r_amount = credits.sum(:refundable_amount)

  next if new_amount == last.final_balance && new_r_amount == last.final_refundable_balance

  new_amount = last.final_balance - new_amount
  new_r_amount = last.final_refundable_balance - new_r_amount

  p.customer_credits.create!(amount: new_amount,
                             refundable_amount: new_r_amount,
                             final_balance: last.final_balance,
                             final_refundable_balance: last.final_refundable_balance,
                             payment_method: "credits",
                             created_in_origin_at: last.created_in_origin_at + 60,
                             transaction_origin: "script")

end

# cambia el credit_value
event = Event.find(8)
CustomerCredit.where(profile: event.profiles).update_all(credit_value: 2.75)
CreditTransaction.where(event: event).update_all(credit_value: 2.75)
ActiveRecord::Base.transaction do
  MoneyTransaction.where(event: event).each do |t|
    t.update! price: t.price * 2.75
  end
end






