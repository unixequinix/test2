class GtagMerger < ActiveJob::Base
  def perform(tag_ids) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    tags = Gtag.find(tag_ids)
    rest = tags.drop(1)
    first = tags.first
    first_profile = first.assigned_profile.id
    rest.each do |tag|
      profile = tag.assigned_profile
      next unless profile
      profile.credit_transactions.update_all(profile_id: first_profile)
      profile.orders.update_all(profile_id: first_profile)
      profile.claims.update_all(profile_id: first_profile)
      profile.customer_orders.update_all(profile_id: first_profile)
      Transaction::TYPES.each do |t|
        klass = Transaction.class_for_type(t)
        klass.where(event_id: 2, profile: profile).update_all(profile_id: first_profile)
      end
      profile.customer_credits.update_all(profile_id: first_profile)
      profile.destroy!
      tag.destroy!
    end
  end
end
