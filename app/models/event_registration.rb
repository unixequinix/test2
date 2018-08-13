class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user

  # User is allowed to have only one role in a specific event
  validates :event_id, uniqueness: { scope: :user_id }, presence: true
  validates :user_id, uniqueness: { scope: :event_id }, presence: true

  enum role: { promoter: 1, support: 2, device_register: 3, staff_manager: 4, gates_manager: 5, monetary_manager: 6, vendor_manager: 7, pos_money_manager: 8, pos_stock_manager: 9 }
end
