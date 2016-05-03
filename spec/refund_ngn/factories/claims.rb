# == Schema Information
#
# Table name: claims
#
#  id                        :integer          not null, primary key
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  total                     :decimal(8, 2)    not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  gtag_id                   :integer
#  service_type              :string
#  fee                       :decimal(8, 2)    default(0.0)
#  minimum                   :decimal(8, 2)    default(0.0)
#  profile_id :integer
#

FactoryGirl.define do
  factory :claim do
    profile
    number { rand(10_000_000) }
    total 9.98
    gtag
    aasm_state { %w(started in_progress completed cancelled).sample }
    service_type(%w(bank_account epg).sample)
  end
end
