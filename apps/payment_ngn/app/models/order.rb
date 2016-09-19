# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  number       :string           not null
#  aasm_state   :string           not null
#  profile_id   :integer
#  completed_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Order < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :profile
  has_many :order_items
  has_many :payments
  has_many :catalog_items, through: :order_items, class_name: "CatalogItem"

  # Validations
  validates :profile, :number, :aasm_state, presence: true
  validate :max_credit_reached

  # State machine
  include AASM

  aasm do
    state :started, initial: true
    state :in_progress
    state :completed, enter: :complete_order

    event :start_payment do
      transitions from: [:started, :in_progress], to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end

  def total_formated
    format("%.2f", total)
  end

  def total
    order_items.to_a.sum(&:total)
  end

  def total_credits
    order_items.to_a.sum(&:credits)
  end

  def total_refundable_credits
    order_items.joins(:catalog_item)
               .where.not(catalog_items: { catalogable_type: "Pack" })
               .to_a.sum(&:credits)
  end

  def generate_order_number!
    self.number = Order.generate_token
    save
  end

  def expired?
    Time.zone.now > created_at + 15.minutes
  end

  # TODO: This method shouldn't be here I extracted it to test it, because we had a bug related to it
  def self.generate_token(date=Time.zone.now)
    time_hex = date.strftime("%H%M%S%L").to_i.to_s(16)
    day = date.strftime("%y%m%d").to_i.to_s(16) 
    "#{day}#{time_hex}"
  end

  private

  def max_credit_reached
    return unless profile
    max_credits = profile.event.get_parameter("gtag", "form", "maximum_gtag_balance").to_f
    max_credits_reached = profile.credits + total_credits > max_credits
    errors.add(:credits, I18n.t("errors.messages.max_credits_reached")) if max_credits_reached
  end

  def complete_order
    update(completed_at: Time.zone.now)
  end
end
