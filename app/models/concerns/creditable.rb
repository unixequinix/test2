module Creditable
  extend ActiveSupport::Concern

  def number
    id.to_s.rjust(7, "0")
  end

  def money_total
    money_fee + money_base
  end

  def credit_total
    credit_fee + credit_base
  end
end
