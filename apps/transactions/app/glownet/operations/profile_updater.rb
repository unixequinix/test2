class ProfileUpdater < ActiveJob::Base
  def perform(id, atts)
    Profile.find(id).update! atts
  end
end
