# == Schema Information
#
# Table name: admissions
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer
#  ticket_id                 :integer
#  deleted_at                :datetime
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
require 'rails_helper'

RSpec.describe Admission, type: :model do
  describe 'ticket_belongs_to_current_event' do
    it 'should validate that the ticket belongs to the current event' do
      admission = build(:admission)
      admission.ticket.event = admission.customer_event_profile.event
      admission.valid?

      expect(admission.errors[:ticket_id].any?).to be(false)
    end
    it 'should add an error if the ticket does not belongs to current event' do
      admission = build(:admission)
      admission.ticket.event = create(:event)
      admission.valid?

      expect(admission.errors[:ticket_id].any?).to be(true)
    end
  end
end
