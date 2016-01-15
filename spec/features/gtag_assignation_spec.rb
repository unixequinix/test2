require 'rails_helper'

RSpec.feature 'Gtag assignation', type: :feature do
  context 'with account signed in' do
    before :all do
      event_parameters = event_to_hash_parameters(build(:event, gtag_registration: true))
      @event_creator = EventCreator.new(event_parameters)
      @event_creator.save
      @event = @event_creator.event
      ep = EventParameter.find_by(event: Event.first, parameter: 1)
      ep.value = 'standard'
      @gtag_format = 'standard' if ep.save
      @customer = build(:customer, event: @event, confirmation_token: nil, confirmed_at: Time.now)
      create(:customer_event_profile, customer: @customer, event: @event)

      login_as(@customer, scope: :customer)
    end

    describe 'a customer ' do
      before :each do
        @gtag = create(:gtag, event: @event)
      end

<<<<<<< HEAD
      it "should be able to assign a gtag" do
        visit "/#{@event_creator.event.slug}/gtag_assignments/new"
        within("form") do
=======
      it 'should be able to assign a gtag' do
        visit "/#{@event_creator.event.slug}/gtag_registrations/new"
        within('form') do
>>>>>>> cleaning
          fill_in(t("gtag_registrations.placeholders.#{@gtag_format}.line_1"), with: @gtag.tag_serial_number)
          fill_in(t("gtag_registrations.placeholders.#{@gtag_format}.line_2"), with: @gtag.tag_uid)
        end
        click_button(t('gtag_registrations.button'))
        expect(current_path).to eq("/#{@event_creator.event.slug}")
      end
    end
  end
end
