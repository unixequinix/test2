module AnalyticsHelper
  include ApplicationHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }
  end

  def transformer(arr, format, denominator)
    arr.map { |t| t["dm1"] }.uniq.map do |dm1|
      selected = arr.select { |t| t["dm1"] == dm1 }
      total_num = selected.map { |t| t["metric"] }.compact.sum

      case format
        when "currency"
          avg = number_to_event_currency(total_num / denominator)
          total = number_to_event_currency(total_num)
          dm2 = selected.map { |t| { t["dm2"] => number_to_event_currency(t["metric"]) } }
        when "token"
          avg = number_to_token(total_num / denominator)
          total = number_to_token(total_num)
          dm2 = selected.map { |t| { t["dm2"] => number_to_token(t["metric"]) } }
        else
          avg = total_num / denominator
          total = total_num
          dm2 = selected.map { |t| { t["dm2"] => t["metric"] } }
      end

      { "dm1" => dm1, "total" => total, "avg" => avg, "dm2" => dm2 }
    end
  end
end
