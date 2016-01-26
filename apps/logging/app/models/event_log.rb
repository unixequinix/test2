class EventLog < ActiveRecord::Base
  belongs_to :event
  belongs_to :customer_event_profile

  def self.write(type, atts)
    klass = type.camelcase.constantize
    klass.create atts
  end

  def self.delay_write(type, atts)
    klass = type.camelcase.constantize
    klass.delay.create atts
  end
end