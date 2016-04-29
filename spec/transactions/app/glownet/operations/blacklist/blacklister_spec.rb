require "rails_helper"

RSpec.describe Operations::Blacklist::Blacklister, type: :job do
  let(:worker) { Operations::Blacklist::Blacklister }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:profile) { create(:profile, event: event) }

  describe ".perform" do
    it "blacklists an object" do
      params = { event_id: event.id, blacklisted_id: ticket.id, blacklisted_type: "ticket" }
      worker.perform_now(params)
      expect(ticket.reload).to be_blacklist
    end

    it "works with gtags" do
      params = { event_id: event.id, blacklisted_id: gtag.id, blacklisted_type: "gtag" }
      worker.perform_now(params)
      expect(gtag.reload).to be_blacklist
    end

    it "raises an error when blacklisting tickets from a different event" do
      ticket.update(event: create(:event))
      params = { event_id: event.id, blacklisted_id: ticket.id, blacklisted_type: "ticket" }
      expect { worker.perform_now(params) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "blacklists all the credentials if the object is a customer event profile" do
      params = {
        event_id: event.id,
        blacklisted_id: profile.id,
        blacklisted_type: "profile"
      }

      CredentialAssignment.create!(profile: profile, credentiable: gtag)
      CredentialAssignment.create!(profile: profile, credentiable: ticket)

      worker.perform_now(params)

      expect(profile.reload).to be_blacklist
      expect(gtag.reload).to be_blacklist
      expect(ticket.reload).to be_blacklist
    end
  end
end
