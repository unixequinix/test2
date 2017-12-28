module StatValidator
  class << self
    def validate_all(stat)
      action = stat.operation.action

      @error_code = validate_date(stat.event, stat.date)
      @error_code ||= validate_quantity_sale_refund(stat) if action == 'sale_refund'
      @error_code ||= validate_quantity_sale(stat) if action == 'sale'
      # @error_code ||= validate_sales(stat) if %w[sale sale_refund].include?(action)

      @error_code
    end

    private

    def validate_sales(stat)
      # TODO: stats ETL for new credit transaction, expect to use line_counter instead of add
      # sale_item_id on Stat table in order to find sale_item related to stat

      # sale_item = stat.operation.sale_items.find_by!(line_counter: stat.line_counter)
      # sale_item_total_price = sale_item.unit * sale_item.standard_unit_price
      # stat_sale_item_total_price = stat.sale_item_total_price

      # Stat.error_codes.key(2) if stat_sale_item_total_price.to_d != sale_item_total_price.to_d
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
