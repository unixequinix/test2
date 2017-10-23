module StatFixer
  class << self
    def fix(stat)
      send("fix_#{stat.error_code}", stat) if stat.error_code.present?
      stat
    end

    def fix_timing_issue(stat)
      # TODO
    end

    def fix_sale_total_quantity(stat)
      # TODO
    end

    def fix_sale_total_price(stat)
      # TODO
    end
  end
end
