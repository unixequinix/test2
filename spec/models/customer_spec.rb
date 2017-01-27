# == Schema Information
#
# Table name: customers
#
#  address                    :string
#  agreed_event_condition     :boolean          default(FALSE)
#  agreed_on_registration     :boolean          default(FALSE)
#  banned                     :boolean
#  birthdate                  :datetime
#  city                       :string
#  country                    :string
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :citext           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string           default(""), not null
#  gender                     :string
#  last_name                  :string           default(""), not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  locale                     :string           default("en")
#  phone                      :string
#  postcode                   :string
#  receive_communications     :boolean          default(FALSE)
#  receive_communications_two :boolean          default(FALSE)
#  remember_token             :string
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#
# Indexes
#
#  index_customers_on_event_id              (event_id)
#  index_customers_on_remember_token        (remember_token) UNIQUE
#  index_customers_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_0b9257e0c6  (event_id => events.id)
#

require "spec_helper"

RSpec.describe Customer, type: :model do
  let(:customer) { build(:customer) }

  describe ".full_name" do
    it "return the first_name and last_name together" do
      allow(subject).to receive(:first_name).and_return("Glownet")
      allow(subject).to receive(:last_name).and_return("Test")
      expect(subject.full_name).to eq("Glownet Test")
    end
  end

  context "with a new customer" do
    describe "the phone" do
      it "is not required" do
        customer = Customer.new(phone: "+34660660660")
        customer.valid?
        expect(customer.errors[:phone]).to eq([])
      end
    end

    describe "the email" do
      %w(customer.foo.com customer@test _@test.).each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          customer.email = wrong_mail
        end
      end
    end

    describe "the birthdate" do
      it "is a date" do
        expect(customer.birthdate.is_a?(ActiveSupport::TimeWithZone)).to eq(true)
      end
    end
  end
end
