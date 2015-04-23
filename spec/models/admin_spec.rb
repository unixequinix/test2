require 'rails_helper'

RSpec.describe Admin, type: :model do

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }

  context "with a new admin" do

    before do
      @admin = build(:admin)
    end

    describe "the password" do

      it "is ok if valid" do
        @admin.password = "validpsswd2"
        expect(@admin).to be_valid
      end

      { "too short" => "x",
        "too long" => "longpassword" * 10,
        "empty" => ""
      }.each do |problematic, password|
        it "cannot be #{problematic}" do
          @admin.password = password
          expect(@admin).not_to be_valid
          expect(@admin.errors["password"]).to be_any
        end
      end

    end

    describe "the email" do

      %w( admin.foo.com admin@test _@test. ).each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          @admin.email = wrong_mail
          expect(@admin).to be_invalid
        end
      end

    end

  end
end
