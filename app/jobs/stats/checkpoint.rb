class Stats::Checkpoint < Stats::Base
  include StatsHelper

  TRIGGERS = %w[access_checkpoint].freeze

  def perform(transaction_id)
    t = AccessTransaction.find(transaction_id)

    create_stat(extract_atts(t, extract_catalog_item_info(t.access, action: "checkpoint", access_direction: t.direction)))
  end
end
