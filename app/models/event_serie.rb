class EventSerie < ApplicationRecord
  has_many :events

  validates :name, presence: true, allow_blank: false
end
