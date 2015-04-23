require 'rails_helper'

RSpec.describe Customer, type: :model do

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:surname) }

  context 'with a new customer' do

    before do
      @customer = create(:customer)
    end

    describe 'the password' do

      it 'is ok if valid' do
        @customer.password = 'validpsswd2'
        expect(@customer).to be_valid
      end

      { 'too short' => 'x',
        'too long' => 'longpassword' * 10,
        'empty' => ''
      }.each do |problematic, password|
        it 'cannot be #{problematic}' do
          @customer.password = password
          expect(@customer).not_to be_valid
          expect(@customer.errors['password']).to be_any
        end
      end

    end

    describe "the email" do

      %w( customer.foo.com customer@test _@test. ).each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          @customer.email = wrong_mail
          expect(@customer).to be_invalid
        end
      end

    end

  end

end