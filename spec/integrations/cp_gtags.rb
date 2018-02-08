require 'rails_helper'

RSpec.describe "GTags in customer portal", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:customer) { create(:customer, event: event) }
  let!(:new_gtag) { create(:gtag, event: event) }
  before(:each) do
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
  end

  describe "add gtag" do
    before(:each) { click_link("add_new_gtag_link") }

    it "correctly" do
      within("#new_gtag") { fill_in 'gtag_reference', with: new_gtag.reference }
      expect { find("input[name=commit]").click }.to change(customer.gtags, :count).by(1)
    end

    it "non-existent" do
      within("#new_gtag") { fill_in 'gtag_reference', with: "12345" }
      expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)
    end

    it "banned" do
      new_gtag.update banned: true
      within("#new_gtag") { fill_in 'gtag_reference', with: new_gtag.reference }
      expect { find("input[name=commit]").click }.not_to change(customer.gtags, :count)
    end
  end

  describe "gtag actions:" do
    let!(:gtag) { create(:gtag, event: event, customer: customer) }
    before do
      visit customer_root_path(event)
    end

    it "select a gtag" do
      click_link(gtag.tag_uid.to_s)
      expect(page).to have_current_path(event_gtag_path(event, gtag))
    end

    it "unassign gtag" do
      visit event_gtag_path(event, gtag)
      click_link("unassign_gtag")
      expect { click_link("ban_confirmation") }.to change { gtag.reload.banned }.to(true)
    end
  end
end
