require 'rails_helper'

RSpec.describe "Create new Accesses", js: true, type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :admin) }
  let(:pack) { create(:pack) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_packs_path(event)
  end

  describe "Creating packs correctly" do
    before(:each) do
      visit admins_event_accesses_path(event)
      find("#floaty").click
      find_link("new_pack_link").click
    end

    it "Is located in /packs" do
      expect(page).to have_current_path new_admins_event_pack_path(event)
    end

    it "Can not be created without filling Name" do
      within("#new_pack") do
        find(".add_fields").click
        first('.grouped_select option', minimum: 1).select_option
        #-------------------------AMOUNT EN ITEM
      end

      expect { find("input[name=commit]").click }.not_to change(Pack, :count)
      expect(page).to have_current_path(admins_event_packs_path(event))
    end

    it "Can not be created without adding one Item" do
      within("#new_pack") do
        fill_in 'pack_name', with: "TESTPACK"
      end

      expect { find("input[name=commit]").click }.not_to change(Pack, :count)
      expect(page).to have_current_path(admins_event_packs_path(event))
    end
  end
end
