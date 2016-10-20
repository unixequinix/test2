# == Schema Information
# require "../../../../apps/core/app/models/event"

# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  event_id          :integer          not null
#

require "rails_helper"

RSpec.describe Gtag, type: :model do
  let(:gtag) { create(:gtag) }
  let(:event) { gtag.event }

  describe ".upcase_gtag!" do
    it "sets the tag_uid in upcase on validation" do
      gtag.tag_uid = "abc123abc"
      gtag.upcase_gtag!
      expect(gtag.tag_uid =~ /[[:upper:]]+$/).not_to be_nil
    end
  end
end
