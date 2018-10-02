require 'rails_helper'

RSpec.describe "Gtag assignment ", type: :feature do
  let(:event) { create(:event, state: "created") }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }
  let(:gtag) { create(:gtag, event: event) }

  before do
    login_as(customer, scope: :customer)
    visit new_event_gtag_assignment_path(event)
  end

  it "can activate a valid gtag" do
    within("#new_gtag") { fill_in 'gtag_reference', with: gtag.reference }

    expect { find("input[name=commit]").click }.to change(customer.gtags, :count).by(1)
    expect(page).to have_current_path(customer_root_path(event))
  end

  it "can't activate an invalid gtag" do
    within("#new_gtag") { fill_in 'gtag_reference', with: "R4ND0M" }

    expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)
    expect(page).to have_current_path(event_gtag_assignments_path(event))
  end

  it "can't activate a banned gtag" do
    gtag.update! banned: true
    within("#new_gtag") { fill_in 'gtag_reference', with: gtag.reference }

    expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)
    expect(page).to have_current_path(event_gtag_assignments_path(event))
  end

  it "can't activate already assigned gtag" do
    gtag.update! customer: create(:customer, event: event, anonymous: false)
    within("#new_gtag") { fill_in 'gtag_reference', with: gtag.reference }

    expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)
    expect(page).to have_current_path(event_gtag_assignments_path(event))
  end
end
