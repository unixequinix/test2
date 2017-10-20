class Stats::Message < Stats::Base
  include StatsHelper

  TRIGGERS = %w[exhibitor_note].freeze

  def perform(transaction_id)
    t = UserEngagementTransaction.find(transaction_id)
    create_stat(extract_atts(t, message: t.message, priority: t.priority.to_i))
  end
end
