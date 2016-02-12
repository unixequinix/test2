# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ActiveRecord::Base
  has_many :company_ticket_types
  has_one :mondonger,
          -> (object) { where("name = ?", object.yeah) },
          class_name: "CompanyTicketType"

  belongs_to :event

  # Validations
  validates :name, :event_id, presence: true
  validates_uniqueness_of :name, scope: :event_id
end
