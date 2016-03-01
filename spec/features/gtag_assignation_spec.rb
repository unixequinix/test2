require "rails_helper"

RSpec.feature "Gtag assignation", type: :feature do
  context "with account signed in" do
    before :all do
      event_parameters = event_to_hash_parameters(build(:event, gtag_assignation: true))
      @event_creator = EventCreator.new(event_parameters)
      @event_creator.save
      @event = @event_creator.event
      ep = EventParameter.find_by(event: @event, parameter: 1)
      ep.value = "standard"
      @gtag_format = "standard" if ep.save
      @customer = build(:customer, event: @event)
      create(:customer_event_profile, customer: @customer, event: @event)

      login_as(@customer, scope: :customer)
    end

    describe "a customer " do
      before :each do
        @gtag = create(:gtag, event: @event)
      end

      it "should be able to assign a gtag" do
        visit "/#{@event_creator.event.slug}/gtag_assignments/new"
        within("form") do
          line1 = "gtag_assignations.placeholders.#{@gtag_format}.line_1"
          line2 = "gtag_assignations.placeholders.#{@gtag_format}.line_2"
          fill_in(t(line1), with: @gtag.tag_serial_number)
          fill_in(t(line2), with: @gtag.tag_uid)
        end
        click_button(t("gtag_assignations.button"))
        expect(current_path).to eq("/#{@event_creator.event.slug}")
      end
    end
  end
end
