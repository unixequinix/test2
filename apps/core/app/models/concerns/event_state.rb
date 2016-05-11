module EventState
  extend ActiveSupport::Concern

  included do
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
        # TODO: Validates Company Ticket Types
        # TODO: Validates Device Private Key
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
  end
end
