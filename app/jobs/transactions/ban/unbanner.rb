class Transactions::Ban::Unbanner < Transactions::Base
  TRIGGERS = %w( ).freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    method_name = atts[:banneable_type].downcase.pluralize.to_sym
    obj = event.method(method_name).call.find(atts[:banneable_id])
    return if !obj.is_a?(Profile) && obj.profile&.banned?
    obj.update!(banned: false)
  end
end
