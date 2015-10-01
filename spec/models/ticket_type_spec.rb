# == Schema Information
#
# Table name: ticket_types
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  company         :string           not null
#  credit          :decimal(8, 2)    default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  simplified_name :string
#

require "rails_helper"

RSpec.describe TicketType, type: :model do

  before do
    @first_event = create(:event)
    create(:ticket_type, name: "repellendus", id: 16, event: @first_event)
    create(:ticket_type, name: "tenetur", id: 17, event: @first_event)
    create(:ticket_type, name: "est", id: 18, event: @first_event)
    create(:ticket_type, name: "in", id: 19, event: @first_event)
    create(:ticket_type, name: "labore", id: 20, event: @first_event)
    @second_event = create(:event)
    create(:ticket_type, name: "repellendus is", id: 21, event: @second_event)
    create(:ticket_type, name: "tenetur is", id: 22, event: @second_event)
    create(:ticket_type, name: "est is", id: 23, event: @second_event)
    create(:ticket_type, name: "in is", id: 24, event: @second_event)
    create(:ticket_type, name: "labore is", id: 25, event: @second_event)
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:company) }
  it { is_expected.to validate_presence_of(:credit) }

  it "creates an array for the selectors" do
    expect(TicketType.form_selector(@first_event)).to eq([
      ["repellendus", 16],
      ["tenetur", 17],
      ["est", 18],
      ["in", 19],
      ["labore", 20]
    ])
  end

end
