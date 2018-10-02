module PokesHelper
  def extract_credit_atts(credit_id, payment, extra_atts = {})
    return {}.merge(extra_atts) unless credit_id

    payment.symbolize_keys!

    credit = CatalogItem.find(credit_id)

    { credit: credit,
      credit_amount: payment[:amount].to_f,
      credit_name: credit.name,
      sale_item_unit_price: payment[:unit_price],
      final_balance: payment[:final_balance] }.merge(extra_atts)
  end

  def extract_sale_item_atts(item, counter, extra_atts = {})
    return {}.merge(extra_atts) unless item

    {
      product_id: item.product_id,
      sale_item_quantity: item.quantity,
      standard_unit_price: item.standard_unit_price,
      standard_total_price: item.standard_total_price,
      line_counter: counter,
      voucher_amount: item.quantity - item.payments.map { |_, data| data["unit_price"].to_i.zero? ? item.quantity.to_f : (data["amount"].to_f / data["unit_price"].to_f) }.select(&:positive?).sum
    }.merge(extra_atts)
  end

  def extract_money_atts(transaction, extra_atts = {})
    { payment_method: transaction.payment_method,
      monetary_quantity: 1,
      monetary_unit_price: transaction.price,
      monetary_total_price: transaction.price }.merge(extra_atts)
  end

  def extract_catalog_item_info(item, extra_atts = {})
    return {}.merge(extra_atts) unless item

    { catalog_item_id: item.id, catalog_item_type: item.class.to_s }.merge(extra_atts)
  end

  def extract_credential_info(credential, extra_atts = {})
    return {}.merge(extra_atts) unless credential

    atts = { ticket_type_id: credential.ticket_type_id }
    atts[:ticket_id] = credential.id if credential.is_a?(Ticket)
    atts.merge(extra_atts)
  end

  def extract_atts(transaction, extra_atts = {})
    return {}.merge(extra_atts) unless transaction

    { operation_id: transaction.id,
      date: Time.zone.parse(transaction.device_created_at_fixed),
      action: transaction.action,
      event_id: transaction.event_id,
      line_counter: 1,
      device_id: transaction.device_id,
      station_id: transaction.station_id,
      operator_id: transaction.operator_id,
      operator_gtag_id: transaction.operator_gtag_id,
      customer_id: transaction.customer_id,
      customer_gtag_id: transaction.gtag_id,
      gtag_counter: transaction.gtag_counter,
      status_code: transaction.status_code }.merge(extra_atts)
  end

  def create_poke(atts)
    begin
      poke = Poke.find_or_initialize_by(atts.slice(:event_id, :line_counter, :operation_id))
      return poke unless poke.new_record?

      poke.update!(atts)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    poke
  end
end
