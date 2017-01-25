# == Schema Information
#
# Table name: admins
#
#  access_token           :string           not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#
# Indexes
#
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#

require "spec_helper"

RSpec.describe Admin, type: :model do
  subject { build(:admin) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".valid_token?" do
    it "returns true if the token is valid" do
      subject.access_token = "0000000001"
      expect(subject.valid_token?("0000000001")).to be_truthy
    end
  end

  describe ".customer_service?" do
    it "returns true if the email starts with support_" do
      subject.email = "support_glownet@glownet.com"
      expect(subject).to be_customer_service
    end
  end

  describe ".promoter?" do
    it "returns true if the email starts with admin_" do
      subject.email = "admin_glownet@glownet.com"
      expect(subject).to be_promoter
    end
  end
end
