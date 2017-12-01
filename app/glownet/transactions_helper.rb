module TransactionsHelper
  def create_gtag(tag_uid, event_id)
    # ticket_activation transactions dont have tag_uid
    return unless tag_uid

    Gtag.find_or_create_by(tag_uid: tag_uid, event_id: event_id)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
