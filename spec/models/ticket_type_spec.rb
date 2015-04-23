require 'rails_helper'

RSpec.describe TicketType, type: :model do

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:company) }
  it { is_expected.to validate_presence_of(:credit) }

  context "with a new ticket_type" do

    before do
      @ticket_type = build(:ticket_type)
    end

    describe "the password" do

      it "is ok if valid" do
        @ticket_type.password = "validpsswd2"
        expect(@ticket_type).to be_valid
      end

      { "too short" => "x",
        "too long" => "longpassword" * 10,
        "empty" => ""
      }.each do |problematic, password|
        it "cannot be #{problematic}" do
          @ticket_type.password = password
          expect(@ticket_type).not_to be_valid
          expect(@ticket_type.errors["password"]).to be_any
        end
      end

    end

    describe "the email" do

      %w( ticket_type.foo.com ticket_type@test _@test. ).each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          @ticket_type.email = wrong_mail
          expect(@ticket_type).to be_invalid
        end
      end

    end

  end
end
