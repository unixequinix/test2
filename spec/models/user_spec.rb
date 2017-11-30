require "rails_helper"

RSpec.describe Customer, type: :model do
  let(:event) { create(:event) }
  let(:user) { create(:user) }

  describe "#password" do
    it "must be longer than 7 characters" do
      user.password = "Aa4"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 7 characters)")
    end

    it "must include at least one lowercase letter and one digit" do
      user.password = "glownet"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must include at least one lowercase letter and one digit")
    end

    it "is valid password" do
      user.password = "gl0wn3T"
      expect(user).to be_valid
    end

    it "must be present" do
      user.password = nil
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end
end
