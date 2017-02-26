class Company < ActiveRecord::Base
  has_many :ticket_types

  belongs_to :event

  validates :name, presence: true
  validates :name, uniqueness: { scope: :event_id }
  validates :access_token, format: { with: /\A[a-zA-Z0-9]+\z/, message: I18n.t("alerts.only_letters_end_numbers") }, allow_nil: true

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless Company.exists?(access_token: access_token)
    end
  end
end
