require "rails_helper"

RSpec.feature "Redsys Setup", type: :feature do

  context "with account signed in" do
    before :each do
      admin = create(:admin)
      login_as(admin, scope: :admin)
    end

    describe "new event and redsys payment system selection" do
      before :each do
        @form_i18n = "simple_form.labels.event.new"
      end

      it "fills and save the event" do
        visit "/admins/events/new"
        within("#new_event") do
          fill_in(t("#{@form_i18n}.name"), with: "Test")
          select("Redsys", from: "event_payment_service")
        end
        click_button(t("helpers.submit.create", model: "Event"))
        expect(page).to have_text(t("admin.defaults.home"))
      end
    end

    describe "event payment settings update" do
      before :each do
        @form_i18n = "simple_form.labels.redsys_payment_settings_form.edit"
      end

      it "fills and save the redsys payment settings" do
        event = create(:event, payment_service: Event::REDSYS)
        visit "/admins/events/#{event.slug}/payment_settings/edit"
        within("#new_redsys_payment_settings_form") do
          fill_in(t("#{@form_i18n}.name"), with: "Live Nation Esp SAU")
          fill_in(t("#{@form_i18n}.code"), with: "126327360")
          fill_in(t("#{@form_i18n}.terminal"), with: "6")
          fill_in(t("#{@form_i18n}.password"), with: "qwertyasdf0123456789")
          fill_in(t("#{@form_i18n}.currency"), with: "978")
          fill_in(t("#{@form_i18n}.transaction_type"), with: "0")
          fill_in(t("#{@form_i18n}.pay_methods"), with: "T")
          fill_in(t("#{@form_i18n}.ip"), with: "195.76.9.247")
          fill_in(t("#{@form_i18n}.form"), with: "https://sis-t.redsys.es:25443/sis/realizarPago")
        end
        click_button(t("admin.actions.update"))
        expect(page).to have_text(t("actions.edit"))
      end
    end
  end
end
