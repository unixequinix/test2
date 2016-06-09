class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def index
    @issues = []

    current_event.profiles.each do |profile|
      next unless profile.insconsistent_credits?
      @issues << {
        profile: profile,
        credits: profile.credits,
        refundable_credits: profile.refundable_credits,
        gtag: profile.assigned_gtag_credential.credentiable.tag_uid
      }
    end
  end
end
