# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  name                    :string           not null
#  aasm_state              :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string           not null
#  location                :string
#  start_date              :datetime
#  end_date                :datetime
#  description             :text
#  support_email           :string           default("support@glownet.com"), not null
#  style                   :text
#  logo_file_name          :string
#  logo_content_type       :string
#  logo_file_size          :integer
#  logo_updated_at         :datetime
#  background_file_name    :string
#  background_content_type :string
#  background_file_size    :integer
#  background_updated_at   :datetime
#  url                     :string
#  background_type         :string           default("fixed")
#

class Event < ActiveRecord::Base

  #Background Types
  BACKGROUND_FIXED = 'fixed'
  BACKGROUND_REPEAT = 'repeat'

  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT]

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_attached_file :logo,
                    path: 'public/system/event-logos/:id/:filename',
                    url: '/system/event-logos/:id/:basename.:extension'

  has_attached_file :background,
                    path: 'public/system/event-backgrounds/:id/:filename',
                    url: '/system/event-backgrounds/:id/:basename.:extension'

  # Validations
  validates :name, :support_email, presence: true
  validates :name, uniqueness: true
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}


  # State machine
  include AASM

  aasm do
    state :created, initial: true
    state :launched
    state :started
    state :finished
    state :closed

    event :launch do
      transitions from: :created, to: :launched
    end

    event :start do
      transitions from: :launched, to: :started
    end

    event :finish do
      transitions from: :started, to: :finished
    end

    event :close do
      transitions from: :finished, to: :closed
    end

    event :reboot do
      transitions from: :closed, to: :created
    end
  end

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| [I18n.t('admin.event.background_types.' + f), f] }
  end

end
