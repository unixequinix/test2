class Claim < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Service Types
  BANK_ACCOUNT = "bank_account".freeze
  EASY_PAYMENT_GATEWAY = "epg".freeze
  TIPALTI = "tipalti".freeze
  DIRECT = "direct".freeze

  REFUND_SERVICES = [BANK_ACCOUNT, EASY_PAYMENT_GATEWAY, TIPALTI, DIRECT].freeze
  TRANSFER_REFUND_SERVICES = [BANK_ACCOUNT, EASY_PAYMENT_GATEWAY, TIPALTI].freeze

  # Associations
  belongs_to :profile
  has_one :refund
  has_many :claim_parameters
  belongs_to :gtag

  # Validations
  validates :profile, :gtag, :service_type, :number, :total, :aasm_state, presence: true

  # Scopes
  scope :query_for_csv, lambda { |aasm_state, event|
    joins(:profile, :gtag, :refund, profile: :customer)
      .includes(:claim_parameters, claim_parameters: :parameter)
      .where(aasm_state: aasm_state)
      .where(profiles: { event_id: event.id })
      .select("claims.id, profiles.id as profile, customers.first_name, customers.last_name, customers.email,
               gtags.tag_uid, refunds.amount, claims.service_type, claims.created_at")
      .order(:id)
  }

  scope :completed, -> { where("aasm_state = 'completed'") }

  # State machine
  include AASM

  aasm do
    state :started, initial: true
    state :in_progress
    state :completed, enter: :complete_claim
    state :cancelled

    event :start_claim do
      transitions from: [:started, :in_progress], to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end

    event :cancel do
      transitions from: :completed, to: :cancelled
    end
  end

  def generate_claim_number!
    time_hex = Time.zone.now.strftime("%H%M%L").to_i.to_s(16)
    day = Time.zone.today.strftime("%y%m%d")
    self.number = "#{day}#{time_hex}"
  end

  def self.selected_data(aasm_state, event)
    claims = query_for_csv(aasm_state, event)
    headers = []
    extra_columns = {}
    claims.each_with_index do |claim, index|
      extra_columns[index + 1] =
        claim.claim_parameters.each_with_object({}) do |claim_parameter, acum|
          headers |= [claim_parameter.parameter.name]
          acum[claim_parameter.parameter.name] = claim_parameter.value
        end
    end
    [claims, headers, extra_columns]
  end

  private

  def complete_claim
    update(completed_at: Time.zone.now)
  end
end
