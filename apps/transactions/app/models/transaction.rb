class Transaction < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :event
  belongs_to :station
  belongs_to :customer_event_profile

  validates_presence_of :transaction_type
end
