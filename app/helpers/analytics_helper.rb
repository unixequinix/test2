module AnalyticsHelper
  include ApplicationHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }
  end

  def grouper(array)
    array.inject { |memo, el| memo.merge(el) { |_k, old_v, new_v| old_v.to_f + new_v.to_f } } || []
  end

  def formatter(data)
    {
      money_reconciliation: number_to_event_currency(data[:money_reconciliation]),
      outstanding_credits: number_to_token(data[:outstanding_credits]),
      total_sales: number_to_token(data[:total_sales]),
      activations: data[:activations].to_i
    }
  end
end
