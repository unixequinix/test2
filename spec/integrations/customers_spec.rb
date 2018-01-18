require 'rails_helper'

RSpec.describe "Customers", type: :feature do
  
  let(:user) { create(:user, role: "glowball") }
  let(:event) { create(:event, name: "Test Event", state: "created") }
  before(:each) { login_as(user, scope: :user) }
  

  describe "Select a customer" do

    let!(:customer) { create(:customer, event: event, anonymous:false) }
    before(:each) { visit admins_event_customers_path(event) }

    it "select a customer" do
      click_link("email_#{customer.id}").click
      expect(page).to have_current_path(admins_event_customer_path(event, customer))
    end
  end

  describe "actions on customer items" do

    let!(:customer) { create(:customer, event: event, anonymous:false) }
    let(:ticket) { create(:ticket, event: event) }
    let(:gtag) { create(:gtag, event: event) }

    before(:each) { visit admins_event_customer_path(event,customer) }

    it "edit customer info" do
      find("#floaty").click
      find_link("edit_customer_link").click
      expect(page).to have_current_path(edit_admins_event_customer_path(event, customer))
      within("#edit_customer_#{customer.id}") {fill_in 'customer_first_name', with: "Name"}
      expect { find("input[name=commit]").click }.to change { customer.reload.first_name }.to("Name")
      expect(page).to have_current_path(admins_event_customer_path(event, customer))
    end

    it "create new order" do
      find("#floaty").click
      find_link("new_order_link").click
      expect(page).to have_current_path(new_admins_event_order_path(event, customer_id:customer.id))
      within("#new_order") {fill_in 'order_credits', with: "10"}
      expect {find("input[name=commit]").click}.to change(customer.orders, :count).by(1)
      expect(page).to have_current_path(admins_event_customer_path(event, customer))
    end
    

    it "assign a gtag to customer" do
      find("#floaty").click
      find_link("assign_gtag_link").click
      expect(page).to have_current_path(new_admins_event_gtag_assignment_path(event, customer))
      within("#new_gtag"){fill_in 'gtag_reference', with: gtag.reference.to_s}
      expect { find("input[name=commit]").click}.to change(customer.gtags, :count).by(1)
      expect(page).to have_current_path(admins_event_customer_path(event, customer))
    end
    
    it "assign an incorrect gtag to customer" do
      find("#floaty").click
      find_link("assign_gtag_link").click
      expect(page).to have_current_path(new_admins_event_gtag_assignment_path(event, customer))
      within("#new_gtag"){fill_in 'gtag_reference', with: "non-existent"}
      expect { find("input[name=commit]").click}.not_to change(customer.gtags, :count)
    end
    
    it "assign a ticket to customer" do
      find("#floaty").click
      find_link("assign_ticket_link").click
      expect(page).to have_current_path(new_admins_event_ticket_assignment_path(event, customer))
      within 'form' do
        fill_in 'code', with: ticket.code.to_s
      end
      expect { find("input[name=commit]").click}.to change(customer.tickets, :count).by(1)
      expect(page).to have_current_path(admins_event_customer_path(event, customer))
    end
    
    it "assign an incorrect ticket to customer" do
      find("#floaty").click
      find_link("assign_ticket_link").click
      expect(page).to have_current_path(new_admins_event_ticket_assignment_path(event, customer))
      within 'form' do
        fill_in 'code', with: "non-existent"
      end
      expect { find("input[name=commit]").click}.not_to change(customer.tickets, :count)
    end
    
    it "delete a ticket" do
      find("#floaty").click
      find_link("assign_ticket_link").click
      expect(page).to have_current_path(new_admins_event_ticket_assignment_path(event, customer))
      within 'form' do
        fill_in 'code', with: ticket.code.to_s
      end
      expect { find("input[name=commit]").click}.to change(customer.tickets, :count).by(1)
      expect do
        click_link("delete_#{ticket.id}")
      end.to change(customer.tickets, :count).by(-1)
    
    end
  end
  
  
end
