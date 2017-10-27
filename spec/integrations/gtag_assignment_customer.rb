require 'rails_helper'

RSpec.describe "Gtag assignment ", type: :feature do
  let(:event) { create(:event, state: "created") }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }
  let(:gtag) { create(:gtag, event: event) }

  before do
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
    find_link("add_new_gtag_link").click
    expect(page).to have_current_path(new_event_gtag_assignment_path(event))
  end

  it "can activate a valid gtag" do
    within("#new_gtag") { fill_in 'gtag_reference', with: gtag.tag_uid }

    expect { find("input[name=commit]").click }.to change(customer.gtags, :count).by(1)
    expect(page).to have_current_path(customer_root_path(event))
  end

  it "can't activate an invalid gtag" do
    within("#new_gtag") { fill_in 'gtag_reference', with: "R4ND0M" }
    expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)

    expect(page).to have_current_path(event_gtag_assignments_path(event))
  end

  it "can't activate a banned gtag" do
    banned_gtag = create(:gtag, event: event, banned: true)
    within("#new_gtag") { fill_in 'gtag_reference', with: banned_gtag.tag_uid }
    expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)

    expect(page).to have_current_path(event_gtag_assignments_path(event))
  end

  it "can't activate already assigned gtag" do
    create(:customer, event: event, anonymous: false)
    create(:gtag, event: event, customer: event.customers.last)
    within("#new_gtag") { fill_in 'gtag_reference', with: event.gtags.last.tag_uid }
    expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)

    expect(page).to have_current_path(event_gtag_assignments_path(event))
  end
end
