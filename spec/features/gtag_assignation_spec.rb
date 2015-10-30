require "rails_helper"

RSpec.feature "Gtag assignation", type: :feature do

  context "with account signed in" do
    before :all do
      @event_creator = EventCreator.new(build(:event,gtag_registration: true).to_hash_parameters)
      @event_creator.save
      @event = @event_creator.event
      ep = EventParameter.find_by(event: Event.first, parameter: 1)
      ep.value = "standard"
      @gtag_format = "standard" if ep.save
      @customer = build(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)
      create(:customer_event_profile, customer: @customer, event: @event)

      visit "/#{@event_creator.event.slug}/login"
      fill_in(t('simple_form.labels.customer.new.email'), with: @customer.email)
      fill_in(t('simple_form.labels.customer.new..password'), with: @customer.password)
      click_button(t('sessions.new.button'))
    end

    describe "a customer " do
      before :each do
        @gtag = create(:gtag, event: @event)
      end

      it "should be able to assign a gtag" do
        visit "/#{@event_creator.event.slug}/gtag_registrations/new"
        within("form") do
          fill_in(t("gtag_registrations.placeholders.#{@gtag_format}.line_1"), with: @gtag.tag_serial_number)
          fill_in(t("gtag_registrations.placeholders.#{@gtag_format}.line_2"), with: @gtag.tag_uid)
        end
        click_button(t('gtag_registrations.button'))
        expect(current_path).to eq("/#{@event_creator.event.slug}")
      end
    end
  end
end
