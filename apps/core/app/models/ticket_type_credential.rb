# == Schema Information
#
# Table name: ticket_type_credentials
#
#  id                       :integer          not null, primary key
#  company_ticket_type_id :integer
#  preevent_product_id      :integer
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class TicketTypeCredential < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :company_ticket_type
  belongs_to :preevent_product
end
