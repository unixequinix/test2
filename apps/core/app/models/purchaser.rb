class Purchaser < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :credentiable, polymorphic: true, touch: true
end

