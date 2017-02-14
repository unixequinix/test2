# == Schema Information
#
# Table name: gtags
#
#  active                   :boolean          default(TRUE)
#  banned                   :boolean          default(FALSE)
#  credits                  :decimal(8, 2)
#  final_balance            :decimal(8, 2)
#  final_refundable_balance :decimal(8, 2)
#  format                   :string           default("wristband")
#  refundable_credits       :decimal(8, 2)
#
# Indexes
#
#  index_gtags_on_customer_id           (customer_id)
#  index_gtags_on_event_id              (event_id)
#  index_gtags_on_tag_uid               (tag_uid)
#  index_gtags_on_tag_uid_and_event_id  (tag_uid,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_084fd46c5e  (event_id => events.id)
#  fk_rails_70b4405c01  (customer_id => customers.id)
#

require "spec_helper"

RSpec.describe Gtag, type: :model do
  subject { create(:gtag) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
