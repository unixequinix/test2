require "rails_helper"

RSpec.describe Operations::Ban::Banner, type: :job do
  let(:worker) { Operations::Ban::Banner }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:profile) { create(:profile, event: event) }

  describe ".perform" do
    it "bans an object" do
      params = { event_id: event.id, banneable_id: ticket.id, banneable_type: "ticket" }
      worker.perform_now(params)
      expect(ticket.reload).to be_banned
    end

    it "works with gtags" do
      params = { event_id: event.id, banneable_id: gtag.id, banneable_type: "gtag" }
      worker.perform_now(params)
      expect(gtag.reload).to be_banned
    end

    it "raises an error when bans tickets from a different event" do
      ticket.update(event: create(:event))
      params = { event_id: event.id, banneable_id: ticket.id, banneable_type: "ticket" }
      expect { worker.perform_now(params) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "bans all the credentials if the object is a customer event profile" do
      params = {
        event_id: event.id,
        banneable_id: profile.id,
        banneable_type: "profile"
      }

      CredentialAssignment.create!(profile: profile, credentiable: gtag)
      CredentialAssignment.create!(profile: profile, credentiable: ticket)

      worker.perform_now(params)

      expect(profile.reload).to be_banned
      expect(gtag.reload).to be_banned
      expect(ticket.reload).to be_banned
    end
  end
end
