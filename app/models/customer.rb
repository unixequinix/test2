# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  name                   :string           default(""), not null
#  surname                :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  agreed_on_registration :boolean          default(FALSE)
#

class Customer < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order('email') }

  # Constants
  MAIL_FORMAT = Devise.email_regexp
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable

  # Associations
  has_many :admissions
  has_many :assigned_admissions, ->{ where(aasm_state: :assigned) }, class_name: "Admission"
  has_one :assigned_admission, ->{ where(aasm_state: :assigned) }, class_name: "Admission"
  has_many :gtag_registrations
  has_many :assigned_gtag_registrations, ->{ where(aasm_state: :assigned) }, class_name: "GtagRegistration"
  has_one :assigned_gtag_registration, ->{ where(aasm_state: :assigned) }, class_name: "GtagRegistration"
  has_one :ticket, through: :admission
  has_many :orders
  has_many :claims
  has_many :credit_logs
  has_one :completed_claim, ->{ where(aasm_state: :completed) }, class_name: "Claim"

  # Validations
  validates :email, format: { with: MAIL_FORMAT }, presence: true
  validates :name, :surname, :password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }
  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_uniqueness_of :email, conditions: -> { where(deleted_at: nil) }

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def total_credits
    self.credit_logs.sum(:amount).floor
  end

  def ticket_credits
    self.credit_logs.where.not(transaction_type: CreditLog::CREDITS_PURCHASE).sum(:amount).floor
  end

  def purchased_credits
    self.credit_logs.where(transaction_type: CreditLog::CREDITS_PURCHASE).sum(:amount).floor
  end

  def refundable_credits
    self.assigned_gtag_registration.gtag.gtag_credit_log.amount unless self.assigned_gtag_registration.nil? || self.assigned_gtag_registration.gtag.gtag_credit_log.nil?
  end
end
