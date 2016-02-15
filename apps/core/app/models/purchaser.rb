# == Schema Information
#
# Table name: purchasers
#
#  id                    :integer          not null, primary key
#  credentiable_id       :integer          not null
#  credentiable_type     :string           not null
#  first_name            :string
#  last_name             :string
#  email                 :string
#  gtag_delivery_address :string
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Purchaser < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :credentiable, polymorphic: true, touch: true
  validates :first_name, :last_name, :email, presence: true
end
