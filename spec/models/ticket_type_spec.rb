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
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:company) }
  it { is_expected.to validate_presence_of(:credit) }

  before :context do
    5.times do
      FactoryGirl.create(:ticket_type)
    end
    @csv_file = TicketType.to_csv
  end

  describe "the CSV file" do
    it "should have the attributes included in the headers" do
      csv_headers = get_headers_from_csv_file(@csv_file)
      expect(included_in?(csv_headers, TicketType.attribute_names)).to be(true)
    end
    it "should have the same rows as records in DB +1 (for the headers)" do
      expect(@csv_file.count("\n")).to be(TicketType.count() +1)
    end
  end

  private
  def get_headers_from_csv_file file
    file.split("\n").first.split(",")
  end

  def included_in? contained, container
    (contained - container).empty?
  end
end
