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
#  created_at                 :datetime         not null
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :string           default(""), not null
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
#  remember_created_at        :datetime
#  remember_token             :string
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#  updated_at                 :datetime         not null
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

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }

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

  context ".gender_selector" do
    it "returns a valid array of genders for an html selector" do
      I18n.locale = :en
      expect(Customer.gender_selector).to eq([%w(Male male), %w(Female female)])
    end
  end
end
