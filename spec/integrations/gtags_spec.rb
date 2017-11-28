require 'rails_helper'

RSpec.describe "Create a gtag", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  before do
    login_as(user, scope: :user)
    visit admins_event_gtags_path(event)
    find("#floaty").click
    find_link("new_gtag_link").click
  end
  it "is located in gtags/new" do
    expect(page).to have_current_path(new_admins_event_gtag_path(event))
  end

  it "can't be done without filling a tag UID" do
    expect do
      find("input[name=commit]").click
    end.not_to change(Gtag, :count)

    expect(page).to have_current_path admins_event_gtags_path(event)
  end

  it "can't be done with filling a tag UID with less than 8 charachers" do
    expect do
      within("#new_gtag") do
        fill_in 'gtag_tag_uid', with: "TEST"
      end

      find("input[name=commit]").click
    end.not_to change(Gtag, :count)

    expect(page).to have_current_path admins_event_gtags_path(event)
  end

  it "can be done with filling only a tag UID with more than 8 charachers" do
    expect do
      within("#new_gtag") do
        fill_in 'gtag_tag_uid', with: "TESTTEST"
      end

      find("input[name=commit]").click
    end.to change(Gtag, :count).by(1)

    gtag = event.gtags.last
    expect(page).to have_current_path admins_event_gtags_path(event)
    expect(gtag.tag_uid).to eq("TESTTEST")
  end

  it "can be done with filling everything" do
    expect do
      within("#new_gtag") do
        fill_in 'gtag_tag_uid', with: "TESTTEST"
        first('#gtag_ticket_type_id option', minimum: 1).select_option
      end

      find("input[name=commit]").click
    end.to change(Gtag, :count).by(1)

    gtag = event.gtags.last
    expect(page).to have_current_path admins_event_gtags_path(event)
    expect(gtag.tag_uid).to eq("TESTTEST")
  end
end
