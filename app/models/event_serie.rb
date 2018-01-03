class EventSerie < ApplicationRecord
  has_many :events, dependent: :nullify

  validates :name, presence: true, allow_blank: false, uniqueness: true
end
