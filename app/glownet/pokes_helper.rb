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
      line_counter: counter
    }.merge(extra_atts)
  end

  def extract_money_atts(t, extra_atts = {})
    { payment_method: t.payment_method,
      monetary_quantity: 1,
      monetary_unit_price: t.price,
      monetary_total_price: t.price }.merge(extra_atts)
  end

  def extract_catalog_item_info(item, extra_atts = {})
    return {}.merge(extra_atts) unless item

    { catalog_item_id: item.id, catalog_item_type: item.class.to_s }.merge(extra_atts)
  end

  def extract_credential_info(credential, extra_atts = {})
    return {}.merge(extra_atts) unless credential

    { credential: credential,
      ticket_type_id: credential.ticket_type_id,
      company_id: credential.ticket_type&.company_id }.merge(extra_atts)
  end

  def extract_atts(transaction, extra_atts = {})
    return {}.merge(extra_atts) unless transaction
    source = "unknown"
    source = "onsite" if transaction.transaction_origin.eql?("onsite")
    source = "online" if transaction.transaction_origin.in?(%w[admin_panel customer_portal api])

    { operation_id: transaction.id,
      source: source,
      date: transaction.device_created_at,
      action: transaction.action,
      event_id: transaction.event_id,
      line_counter: 1,
      device_id: Device.find_by(mac: transaction.device_uid)&.id,
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
