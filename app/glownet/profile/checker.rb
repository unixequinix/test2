class Profile::Checker
  # rubocop:disable Metrics/CyclomaticComplexity
  def self.for_transaction(gtag, tr_profile, event_id)
    tg_profile = gtag.profile&.id

    if tr_profile.present? && tg_profile.present? && tg_profile != tr_profile
      profile = Profile.find(tr_profile)
      raise "Profile fraud - Profile: #{tr_profile}, Gtag: #{tg_profile}" if profile.active_gtag.present?
      merged = profile_merger(profile, gtag.profile)
      gtag.update!(profile: merged)
      return merged.id
    end

    return tr_profile if tr_profile
    return tg_profile if tg_profile

    Profile.create!(event_id: event_id, gtags: [gtag]).id
  end

  def self.for_credentiable(obj, profile)
    return if obj.assigned?
    obj.update(profile: profile_merger(profile, obj.profile), active: true)
  end

  def self.profile_merger(base, extra)
    return base unless extra
    extra.transactions.update_all(profile_id: base.id)
    extra.destroy
    base.recalculate_balance
    base
  end
end
