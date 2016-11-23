# == Schema Information
#
# Table name: events
#
#  aasm_state                   :string
#  background_content_type      :string
#  background_file_name         :string
#  background_file_size         :integer
#  background_type              :string           default("fixed")
#  background_updated_at        :datetime
#  company_name                 :string
#  created_at                   :datetime         not null
#  currency                     :string           default("USD"), not null
#  device_basic_db_content_type :string
#  device_basic_db_file_name    :string
#  device_basic_db_file_size    :integer
#  device_basic_db_updated_at   :datetime
#  device_full_db_content_type  :string
#  device_full_db_file_name     :string
#  device_full_db_file_size     :integer
#  device_full_db_updated_at    :datetime
#  device_settings              :json
#  end_date                     :datetime
#  eventbrite_client_key        :string
#  eventbrite_client_secret     :string
#  eventbrite_event             :string
#  eventbrite_token             :string
#  gtag_assignation             :boolean          default(FALSE)
#  gtag_settings                :json
#  host_country                 :string           default("US"), not null
#  location                     :string
#  logo_content_type            :string
#  logo_file_name               :string
#  logo_file_size               :integer
#  logo_updated_at              :datetime
#  name                         :string           not null
#  official_address             :string
#  official_name                :string
#  registration_num             :string
#  registration_settings        :json
#  slug                         :string           not null
#  start_date                   :datetime
#  style                        :text
#  support_email                :string           default("support@glownet.com"), not null
#  ticket_assignation           :boolean          default(FALSE)
#  token                        :string
#  token_symbol                 :string           default("t")
#  updated_at                   :datetime         not null
#  url                          :string
#
# Indexes
#
#  index_events_on_slug  (slug) UNIQUE
#

require "spec_helper"

RSpec.describe Event, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:support_email) }
end
