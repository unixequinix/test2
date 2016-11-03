# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  access_token           :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require "rails_helper"

RSpec.describe Admin, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  let(:admin) { build(:admin) }

  context "with a new admin" do
    describe "the email" do
      %w(admin.foo.com admintest _test.).each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          admin.email = wrong_mail
          expect(admin).to be_invalid
        end
      end
    end

    describe "a new token" do
      it "is set" do
        admin = create(:admin)
        expect(admin.access_token).not_to be_nil
      end
    end
  end

  context "with an existing admin" do
    describe "the token" do
      it "can be validated" do
        admin = create(:admin)
        token = admin.access_token
        expect(admin.valid_token?(token)).to eq(true)
      end
    end
  end
end