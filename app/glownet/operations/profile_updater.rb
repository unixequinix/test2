class ProfileUpdater < ActiveJob::Base
  def perform(profile_id, atts)
    Profile.find(profile_id).update(atts)
  end
end
