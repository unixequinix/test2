# == Schema Information
#
# Table name: refunds
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  claim_id                   :integer
#  amount                     :decimal(8, 2)    not null
#  currency                   :string
#  message                    :string
#  operation_type             :string
#  gateway_transaction_number :string
#  payment_solution           :string
#  status                     :string
#

class Refund < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :claim

  # Validations
  validates :claim, :amount, presence: true

  scope :selected_data, lambda  { |event_id|
    joins(:claim, claim:
      [:customer_event_profile, { customer_event_profile: :customer }])
      .select('refunds.*, claims.number, customers.email')
      .where(customer_event_profiles: { event_id: event_id })
  }
end
