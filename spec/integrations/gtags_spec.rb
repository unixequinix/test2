require 'rails_helper'

RSpec.describe "Creating a gtag", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  before do
    login_as(user, scope: :user)
    visit new_admins_event_gtag_path(event)
  end

  it "can't be done without filling a tag UID" do
    expect { find("input[name=commit]").click }.not_to change(Gtag, :count)
  end

  it "can be done only if the UID is larger than 8 characters" do
    within("#new_gtag") { fill_in 'gtag_tag_uid', with: "TEST" }

    expect { find("input[name=commit]").click }.not_to change(Gtag, :count)
    expect(page).to have_current_path admins_event_gtags_path(event)
  end

  it "can't be done if the UID is smaller than 8 characters" do
    within("#new_gtag") { fill_in 'gtag_tag_uid', with: "TESTTEST" }

    expect { find("input[name=commit]").click }.to change(Gtag, :count).by(1)
    expect(page).to have_current_path admins_event_gtags_path(event)
    expect(event.gtags.last.tag_uid).to eq("TESTTEST")
  end

  it "can be done with successfully" do
    within("#new_gtag") do
      fill_in 'gtag_tag_uid', with: "TESTTEST"
      first('#gtag_ticket_type_id option', minimum: 1).select_option
    end

    expect { find("input[name=commit]").click }.to change(Gtag, :count).by(1)
    expect(page).to have_current_path admins_event_gtags_path(event)
    expect(event.gtags.last.tag_uid).to eq("TESTTEST")
  end
end
