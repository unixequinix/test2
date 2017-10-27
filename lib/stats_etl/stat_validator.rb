module StatValidator
  class << self
    def validate_all(stat)
      action = stat.operation.action

      @error_code = validate_date(stat.event, stat.date)
      @error_code ||= validate_quantity_sale(stat) if action == 'sale_refund'
      @error_code ||= validate_quantity_sale(stat) if action == 'sale'
      @error_code ||= validate_sales(stat) if %w[sale sale_refund].include?(action)
    end

    private

    def validate_sales(stat)
      total_price = stat.operation.credits
      stats_sale_item_price = Stat.where(operation: stat.operation).pluck(:sale_item_total_price).sum
      Stat.error_codes.key(2) if stats_sale_item_price.to_d != - total_price.to_d
    end

    def validate_quantity_sale(stat)
      Stat.error_codes.key(1) if stat.action == 'sale' && stat.sale_item_quantity.negative?
    end

    def validate_quantity_sale_refund(stat)
      Stat.error_codes.key(1) if stat.action == 'sale_refund' && stat.sale_item_quantity.positive?
    end

    def validate_date(event, date)
      Stat.error_codes.key(0) unless date.between?(event.start_date, event.end_date)
    end
  end
end
