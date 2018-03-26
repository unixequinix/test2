class Pokes::Sale < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[sale sale_refund].freeze

  def perform(transaction)
    global_index = 0

    transaction.sale_items.map do |item|
      item.payments.to_a.map do |credit_id, payment|
        global_index += 1

        description = item.sale_item_type || transaction.action
        payment[:final_balance] = transaction.payments[credit_id].to_h["final_balance"]
        atts = extract_credit_atts(credit_id, payment, extract_sale_item_atts(item, global_index, description: description, action: "sale"))
        atts[:credit_amount] = -atts[:credit_amount]

        create_poke(extract_atts(transaction, atts))
      end
    end.flatten
  end
end
