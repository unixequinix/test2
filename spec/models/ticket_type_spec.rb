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

require 'rails_helper'

RSpec.describe TicketType, type: :model do

  before do
    FactoryGirl.create(:ticket_type, name: "repellendus", id: 16)
    FactoryGirl.create(:ticket_type, name: "tenetur", id: 17)
    FactoryGirl.create(:ticket_type, name: "est", id: 18)
    FactoryGirl.create(:ticket_type, name: "in", id: 19)
    FactoryGirl.create(:ticket_type, name: "labore", id: 20)
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:company) }
  it { is_expected.to validate_presence_of(:credit) }

  it "creates an array for the selectors" do
    expect(TicketType.form_selector()).to eq([
      ["repellendus", 16],
      ["tenetur", 17],
      ["est", 18],
      ["in", 19],
      ["labore", 20]
    ])
  end

end
