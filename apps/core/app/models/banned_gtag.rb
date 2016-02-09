# == Schema Information
#
# Table name: banned_gtags
#
#  id         :integer          not null, primary key
#  gtag_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BannedGtag < ActiveRecord::Base
  belongs_to :gtag
  validates :gtag_id, uniqueness: true
  validates :gtag_id, presence: true
end
