# == Schema Information
#
# Table name: bank_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  iban        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  swift       :string
#

class BankAccount < ActiveRecord::Base

  # Associations
  belongs_to :customer
  has_many :refunds

  validates :iban, presence: true
  validates_with IbanValidator
end
