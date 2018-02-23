require "rails_helper"

RSpec.describe TeamInvitation, type: :model do
  let(:user) { create(:user) }
  subject { create(:team_invitation, team: create(:team), user: user, leader: true, active: true) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "mush have a valid team" do
    subject.team = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:team]).to include("must exist")
  end

  it "is valid without a user" do
    subject.user = nil
    expect(subject).to be_valid
  end

  it "is inactive by default" do
    subject = build(:team_invitation)
    expect(subject.active).to be false
  end

  describe "invitation flow" do
    before do
      subject.save!
      create(:team_invitation, team: create(:team), user: user)
    end

    it "user can have more team invitations" do
      expect(user.team_invitations.count).to be(2)
    end

    it "can be invited in another team an user with a team" do
      expect { create(:team_invitation, team: create(:team), user: user) }.to change(user.team_invitations, :count).by(1)
    end

    it "can be invited an user without a team" do
      user = create(:user)
      expect { create(:team_invitation, team: create(:team), user: user) }.to change(user.team_invitations, :count).by(1)
    end

    it "can be invited unregistered user" do
      expect { create(:team_invitation, team: user.team) }.to change(TeamInvitation, :count).by(1)
    end

    it "can not invite same user to the same team twice" do
      invitation = build(:team_invitation, team: user.team, user: user)
      expect(invitation).to be_invalid
    end

    it "can not have more than one active invitation" do
      build(:team_invitation, team: create(:team), user: user, active: true)
      build(:team_invitation, team: create(:team), user: user, active: true)
      expect(user.team_invitations.where(active: true).count).to eq(1)
    end
  end
end
