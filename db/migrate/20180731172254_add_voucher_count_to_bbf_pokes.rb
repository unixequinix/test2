class AddVoucherCountToBbfPokes < ActiveRecord::Migration[5.1]
  def change
    event = Event.find_by(id: 428)
    return unless event
    
    SaleItem.where(credit_transaction: event.transactions.where(action: %w[sale sale_refund]).status_ok).each do |item|
      voucher_count = item.quantity - item.payments.map { |_, data| data["amount"].to_f / data["unit_price"].to_f }.select(&:positive?).sum
      next unless voucher_count.positive?

      item.credit_transaction.pokes.find_by(product: item.product).update!(voucher_amount: voucher_count)
    end
  end
end
