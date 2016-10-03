# == Schema Information
#
# Table name: refunds
#
#  id                         :integer          not null, primary key
#  claim_id                   :integer          not null
#  amount                     :decimal(8, 2)    not null
#  currency                   :string
#  message                    :string
#  operation_type             :string
#  gateway_transaction_number :string
#  payment_solution           :string
#  status                     :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Refund < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :claim

  # Validations
  validates :claim, :amount, presence: true

  scope :selected_data, lambda { |event_id|
    joins(claim: { profile: :customer })
      .select("refunds.*, claims.number, customers.email")
      .where(profiles: { event_id: event_id })
  }
end
