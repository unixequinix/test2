require "rails_helper"

RSpec.describe EventParameter, type: :model do
  describe "for_category" do
    it "should return the event and the parameters for a category" do
      event_parameter = create(:event_parameter)
      category = event_parameter.parameter.category
      event = event_parameter.event
      expect(EventParameter.for_category(category, event)).not_to be_nil
    end
  end
end

