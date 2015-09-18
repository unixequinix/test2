# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  name                   :string           default(""), not null
#  surname                :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  agreed_on_registration :boolean          default(FALSE)
#

require "rails_helper"

RSpec.describe Customer, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
=begin
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:surname) }

  context "with a new customer" do
    before do
      @customer = create(:customer)
    end

    describe "the password" do
      it "is ok if valid" do
        @customer.password = @customer.password_confirmation = "validpsswd2"
        expect(@customer).to be_valid
      end

      { "too short" => "x",
        "too long" => "longpassword" * 10,
        "empty" => ""
      }.each do |problematic, password|
        it "cannot be #{problematic}" do
          @customer.password = @customer.password_confirmation  = password
          expect(@customer).not_to be_valid
          expect(@customer.errors["password"]).to be_any
        end
      end
    end

    describe "the email" do
      %w(customer.foo.com customer@test _@test.).each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          @customer.email = wrong_mail
          expect(@customer).to be_invalid
        end
      end
    end
  end
=end
end
