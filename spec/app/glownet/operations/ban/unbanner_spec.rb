require "rails_helper"

RSpec.describe Operations::Ban::Unbanner, type: :job do
  let(:worker) { Operations::Ban::Unbanner }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event, banned: true) }
  let(:gtag) { create(:gtag, event: event, banned: true) }
  let(:profile) { create(:profile, event: event, banned: true) }

  describe ".perform" do
    it "unbans an object" do
      params = { event_id: event.id, banneable_id: ticket.id, banneable_type: "ticket" }
      worker.perform_now(params)
      expect(ticket.reload).not_to be_banned
    end

    it "unbans a gtag" do
      params = { event_id: event.id, banneable_id: gtag.id, banneable_type: "gtag" }
      worker.perform_now(params)
      expect(gtag.reload).not_to be_banned
    end

    it "raises an error when bans tickets from a different event" do
      ticket.update(event: create(:event))
      params = { event_id: event.id, banneable_id: ticket.id, banneable_type: "ticket" }
      expect { worker.perform_now(params) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "doesn't unban all the credentials when unbans a profile" do
      atts = { event_id: event.id, banneable_id: profile.id, banneable_type: "profile" }

      CredentialAssignment.create!(profile: profile, credentiable: gtag)
      CredentialAssignment.create!(profile: profile, credentiable: ticket)

      worker.perform_now(atts)

      expect(profile.reload).not_to be_banned
      expect(gtag.reload).to be_banned
      expect(ticket.reload).to be_banned
    end

    it "doesn't unban a ticket if the profile is banned" do
      atts = { event_id: event.id, banneable_id: ticket.id, banneable_type: "ticket" }
      CredentialAssignment.create!(profile: profile, credentiable: ticket)
      worker.perform_now(atts)
      expect(ticket.reload).to be_banned
    end
  end
end
