# == Schema Information
#
# Table name: payment_gateway_customers
#
#  id                 :integer          not null, primary key
#  profile_id         :integer
#  token              :string
#  gateway_type       :string
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  agreement_accepted :boolean          default(FALSE), not null
#  autotopup_amount   :integer
#  email              :string
#

class PaymentGatewayCustomer < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :profile

  AUTOTOPUP_AMOUNTS = [10, 20, 30, 40, 50].freeze

  validates :profile_id, uniqueness: { scope: :gateway_type }
end
