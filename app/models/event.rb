# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  name       :string
#  aasm_state :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Event < ActiveRecord::Base

  # State machine
  include AASM

  aasm do
    state :created, initial: true
    state :started
    state :finished

    event :start do
      transitions from: :created, to: :started
    end

    event :finish do
      transitions from: :started, to: :finished
    end

    event :reboot do
      transitions from: :finished, to: :created
    end
  end

end
