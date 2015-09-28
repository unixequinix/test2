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
#  phone                  :string
#  postcode               :string
#  address                :string
#  city                   :string
#  country                :string
#  gender                 :string
#  birthdate              :datetime
#

class Customer < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order('email') }

  #Genders
  MALE = 'male'
  FEMALE = 'female'

  GENDERS = [MALE, FEMALE]

  # Constants
  MAIL_FORMAT = Devise.email_regexp
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable

  # Associations
  has_many :customer_event_profiles

  # Validations
  validates :email, format: { with: MAIL_FORMAT }, presence: true
  validates :name, :surname, :password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_uniqueness_of :email, conditions: -> { where(deleted_at: nil) }

  validates_format_of :phone, :with => /\A[+]?\d{6,}\Z/
  validates :country, inclusion: { in:Country.all.map(&:pop) }
  validates :gender, inclusion: { in: GENDERS }



  # Methods
  # -------------------------------------------------------

  def self.gender_selector
    GENDERS.map { |f| [I18n.t('gender.' + f), f] }
  end


  # TODO Big mess

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions(attributes[:event_id]) if recoverable.persisted?
    recoverable
  end

  def send_reset_password_instructions(event_id=nil)
    token = set_reset_password_token
    send_reset_password_instructions_notification(token, event_id)
    token
  end

  def send_reset_password_instructions_notification(token, event_id=nil)
    send_devise_notification(:reset_password_instructions, token, {event_id: event_id})
  end

  def self.send_confirmation_instructions(attributes={})
    confirmable = find_by_unconfirmed_email_with_errors(attributes) if reconfirmable
    unless confirmable.try(:persisted?)
      confirmable = find_or_initialize_with_errors(confirmation_keys, attributes, :not_found)
    end
    confirmable.resend_confirmation_instructions(attributes[:event_id]) if confirmable.persisted?
    confirmable
  end

   def resend_confirmation_instructions(event_id=nil)
    pending_any_confirmation do
      send_confirmation_instructions(event_id)
    end
   end

  def send_confirmation_instructions(event_id=nil)
    unless @raw_confirmation_token
      generate_confirmation_token!
    end
    opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
    opts[:event_id] = event_id
    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

end
