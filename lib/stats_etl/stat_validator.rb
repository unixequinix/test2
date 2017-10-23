module StatValidator
  class << self
    def validate_all(stat)
      @error_code = nil
      action = stat.operation.action

      if %w[sale sale_refund].include?(action)
        validate_sales(stat)
        send("validate_quantity_#{action}", stat)
      end

      validate_date(stat.event, stat.date)
      @error_code
    end

    private

    def validate_sales(stat)
      # TODO[fmoya] how to validate it correctly?
      operation_sale_item_total_price = stat.operation.credits
      stats_sale_item_price = Stat.where(operation: stat.operation).pluck(:sale_item_total_price).sum

      @error_code = Stat.error_codes.key(2) if stats_sale_item_price.to_d != - operation_sale_item_total_price.to_d
    end

    def validate_quantity_sale(stat)
      @error_code = Stat.error_codes.key(1) if stat.action == 'sale' && stat.sale_item_quantity.negative?
    end

    def validate_quantity_sale_refund(stat)
      @error_code = Stat.error_codes.key(1) if stat.action == 'sale_refund' && stat.sale_item_quantity.positive?
    end

    def validate_date(event, date)
      @error_code = Stat.error_codes.key(0) unless date.between?(event.start_date, event.end_date)
    end
  end
end
