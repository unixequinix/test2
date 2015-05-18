# == Schema Information
#
# Table name: bank_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  number      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class BankAccount < ActiveRecord::Base

  # Associations
  belongs_to :customer
  has_many :refunds

  validates :number, presence: true
end
