# == Schema Information
#
# Table name: credit_transactions
#
#  id :integer          not null, primary key
#

class CreditTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :customer_event_profile

  validates_presence_of :transaction_type
end
