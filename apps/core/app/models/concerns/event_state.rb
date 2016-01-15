module EventState
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :created, initial: true
      state :launched
      state :started
      state :finished
      state :claiming_started
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

      event :start_claim do
        transitions from: :finished, to: :claiming_started
      end

      event :close do
        transitions from: :claiming_started, to: :closed
      end

      event :reboot do
        transitions from: :closed, to: :created
      end
    end
  end
end
