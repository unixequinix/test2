class Stats::Flag < Stats::Base
  include StatsHelper

  TRIGGERS = %w[user_flag].freeze

  def perform(transaction_id)
    t = UserFlagTransaction.find(transaction_id)
    flag = t.event.user_flags.find_by(name: t.user_flag)
    atts = extract_catalog_item_info(flag).merge(user_flag_value: t.user_flag_active)

    create_stat(extract_atts(t, atts))
  end
end
