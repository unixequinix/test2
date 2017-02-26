class GtagCreator < ActiveJob::Base
  def perform(atts)
    gtag = Gtag.find_or_initialize_by(event_id: atts[:event_id], tag_uid: atts[:tag_uid])
    gtag.update(atts)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
