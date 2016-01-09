require "rails_helper"

RSpec.feature "Ticket assignation", type: :feature do
  context "with account signed in" do
    before :all do
      @event_creator = EventCreator.new(build(:event, features: 3, aasm_state: "launched").to_hash_parameters)
      @event_creator.save
      @event = @event_creator.event
      @customer = build(:customer,
                        event: @event,
                        confirmation_token: nil,
                        confirmed_at: Time.now)
      create(:customer_event_profile, customer: @customer, event: @event)

      login_as(@customer, scope: :customer)
    end

    describe "a customer " do
      before :each do
        @ticket = create(:ticket,
                         event: @event,
                         purchaser_email: @customer.email,
                         purchaser_name: @customer.name,
                         purchaser_surname: @customer.surname
                        )
      end

      it "should be able to assign a ticket" do
        visit "/#{@event_creator.event.slug}/ticket_assignments/new"
        within("form") do
          fill_in(t("admissions.placeholders.ticket_number"), with: @ticket.number)
        end
        click_button(t("admissions.button"))
        expect(current_path).to eq("/#{@event_creator.event.slug}")
        expect(page.body).to include(@ticket.number)
      end
    end
  end
end
