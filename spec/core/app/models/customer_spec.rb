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
#  phone                  :string
#  postcode               :string
#  address                :string
#  city                   :string
#  country                :string
#  gender                 :string
#  birthdate              :datetime
#  event_id               :integer          not null
#

require "rails_helper"

RSpec.describe Customer, type: :model do
  before :each do
    @customer = create(:customer)
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:surname) }

  context ".confirm!" do
    before :each do
      @customer.confirm!
    end

    it "should set the confirmation token to nil" do
      expect(@customer.confirmation_token).to be_nil
    end

    it "should set the confirmed_at with a date" do
      expect(@customer.confirmed_at).to be_kind_of(Time)
    end
  end

  context ".update_tracked_fields" do
    before :each do
      @request = double(:request)
      allow(@request).to receive(:env) { { "REMOTE_ADDR" => "0.0.0.0" } }
    end

    describe "when customer has never logged in" do
      it "sets the last_sign_in_at with a date" do
        expect(@customer.last_sign_in_at).to be_nil
        @customer.update_tracked_fields!(@request)
        expect(@customer.last_sign_in_at).to be_kind_of(Time)
      end

      it "sets the current_sign_in_at with a date" do
        expect(@customer.current_sign_in_at).to be_nil
        @customer.update_tracked_fields!(@request)
        expect(@customer.current_sign_in_at).to be_kind_of(Time)
      end

      it "sets the last_sign_in_ip" do
        expect(@customer.last_sign_in_ip).to be_nil
        @customer.update_tracked_fields!(@request)
        expect(@customer.last_sign_in_ip).to eq("0.0.0.0")
      end

      it "sets the current_sign_in_ip" do
        expect(@customer.current_sign_in_ip).to be_nil
        @customer.update_tracked_fields!(@request)
        expect(@customer.current_sign_in_ip).to eq("0.0.0.0")
      end

      it "sets the sign_in_count to 1" do
        expect(@customer.sign_in_count).to eq(0)
        @customer.update_tracked_fields!(@request)
        expect(@customer.sign_in_count).to eq(1)
      end
    end

    describe "when customer has logged in previously" do
      before :each do
        @customer.update_tracked_fields!(@request)
      end

      it "sets the current_sign_in_at with a date" do
        @customer.update_tracked_fields!(@request)
        expect(@customer.last_sign_in_at).to be_kind_of(Time)
      end

      it "sets the current_sign_in_at with a different date" do
        old_date = @customer.current_sign_in_at
        @customer.update_tracked_fields!(@request)
        expect(@customer.current_sign_in_at).not_to eq(old_date)
      end

      it "sets the last_sign_in_at with the old current_sign_in_ip" do
        old_current = @customer.last_sign_in_at
        @customer.update_tracked_fields!(@request)
        expect(@customer.last_sign_in_at).not_to eq(old_current)
      end

      it "updates the current_sign_in_ip" do
        old_current = @customer.current_sign_in_ip
        allow(@request).to receive(:env) { { "REMOTE_ADDR" => "1.2.3.4" } }
        @customer.update_tracked_fields!(@request)
        expect(@customer.current_sign_in_ip).not_to eq(old_current)
      end

      it "sets the last_sign_in_ip with the old current_sign_in_ip" do
        old_current = @customer.last_sign_in_ip
        allow(@request).to receive(:env) { { "REMOTE_ADDR" => "1.2.3.4" } }
        @customer.update_tracked_fields!(@request)
        expect(@customer.last_sign_in_ip).to eq(old_current)
      end

      it "increases the count by 1" do
        old_count = @customer.sign_in_count
        @customer.update_tracked_fields!(@request)
        expect(@customer.sign_in_count).to eq(old_count + 1)
      end
    end
  end

  context ".init_password_token!" do
    before :each do
      @customer.init_password_token!
    end

    it "should set the password token" do
      expect(@customer.reset_password_token).not_to be_blank
    end

    it "should set the reset_password_sent_at with a date" do
      expect(@customer.reset_password_sent_at).to be_kind_of(Time)
    end
  end

  context ".init_remember_token!" do
    before :each do
      @customer.init_remember_token!
    end

    it "should set the remember token" do
      expect(@customer.remember_token).not_to be_blank
    end

    it "should set the remember_created_at with a date" do
      expect(@customer.remember_created_at).to be_kind_of(Time)
    end
  end

  context ".remember_me_token_expires_at" do
    it "returns the sum of the remember_created_at and the expiration_time given" do
      remember_created_at = Time.now
      expiration_time = 2.weeks
      sum = remember_created_at + expiration_time
      @customer.remember_created_at = remember_created_at
      expect(@customer.remember_me_token_expires_at(2.weeks)).to eq(sum)
    end
  end

  context "with a new customer" do
    describe "confirmation token" do
      it "should be initialised" do
        expect(@customer.confirmation_token).not_to be_blank
      end
    end

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
          @customer.email = wrong_mail
        end
      end
    end

    describe "the birthdate" do
      it "is a date" do
        expect(@customer.birthdate.is_a?(ActiveSupport::TimeWithZone)).to eq(true)
      end
    end
  end

  context ".gender_selector" do
    it "returns a valid array of genders for an html selector" do
      I18n.locale = :en
      expect(Customer.gender_selector).to eq([%w( Male male ), %w( Female female )])
    end
  end
end
