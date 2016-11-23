# == Schema Information
#
# Table name: company_event_agreements
#
#  aasm_state :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_company_event_agreements_on_company_id  (company_id)
#  index_company_event_agreements_on_event_id    (event_id)
#
# Foreign Keys
#
#  fk_rails_52b6bdbbec  (company_id => companies.id)
#  fk_rails_88826edadd  (event_id => events.id)
#

require "spec_helper"

RSpec.describe CompanyEventAgreement, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
