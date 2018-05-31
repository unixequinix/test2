module Validators
  class MissingCounter < ApplicationJob
    queue_as :low

    def perform(transaction)
      transaction.gtag&.validate_missing_counters
    end
  end
end
