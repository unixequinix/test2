class Profile::Checker
  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def self.for_transaction(gtag, tr_profile, event_id)
    tg_profile = gtag.profile&.id

    if tr_profile.present? && tg_profile.present? && tg_profile != tr_profile
      profile = Profile.find(tr_profile)
      message = "Profile fraud - Transaction: #{tr_profile.inspect}, Gtag: #{tg_profile.inspect}"
      raise message if profile.active_gtag.present?

      gtag.update!(profile: profile)

      Transaction::TYPES.each do |type|
        klass = Transaction.class_for_type(type)
        klass.where(profile_id: tg_profile).update_all(profile_id: tr_profile)
      end

      profile.transactions.credit.last.try(:recalculate_profile_balance)
      return tr_profile
    end

    return tr_profile if tr_profile
    return tg_profile if tg_profile

    Profile.create!(event_id: event_id, gtags: [gtag]).id
  end
end
