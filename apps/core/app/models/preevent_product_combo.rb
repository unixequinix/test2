# == Schema Information
#
# Table name: preevent_product_combos
#
#  id                       :integer          not null, primary key
#  preevent_product_unit_id :integer
#  preevent_product_id      :integer
#  amount                   :integer
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class PreeventProductCombo < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :preevent_product_unit
  belongs_to :preevent_product
end
