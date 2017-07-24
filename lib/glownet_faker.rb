class GlownetFaker
  def initialize(slug, amount)
    @event = Event.find_by slug: slug
    @amount = amount
    @values = []
  end

  def tickets
    Rails.logger.info " -- creating #{@amount} tickets for current ticket types"
    @event.ticket_types.each { |tt| @amount.times { |i| @values << [@event.id, tt.id, "#{tt.name}#{i}"] } }
    Ticket.import %i[event_id ticket_type_id code], @values, validate: false
    Rails.logger.info "DONE"
  end

  def gtags
    Rails.logger.info " -- creating #{@amount} gtags for current event"
    @amount.times { |i| @values << ["TAG#{i}", @event.id] }
    Gtag.import %i[tag_uid event_id], @values, validate: false
    Rails.logger.info "DONE"
  end

  def customers
    Rails.logger.info " -- creating #{@amount} customers"
    password = "$2a$11$M4nToRzivPjDzYjzwa9NMu3LY.ZlAxMuJXb0fEd7vVFL/HOlc514u"
    columns = %w[event_id agreed_on_registration email encrypted_password first_name last_name].map(&:to_sym)
    @amount.times { |i| @values << [@event.id, true, "customer#{i}@fake.com", password, "Customer#{i}", "Smith#{i}"] }
    Customer.import columns, @values, validate: false
    Rails.logger.info "DONE"
  end

  def gtags_for_customers
    Rails.logger.info " -- creating #{@amount} gtags for current event"
    @event.customers.pluck(:id).each { |id| @values << ["CUSTTAG#{id}", @event.id, id] }
    Gtag.import %i[tag_uid event_id customer_id], @values, validate: false
    Rails.logger.info "DONE"
  end

  def orders
    Rails.logger.info " -- creating one order per customer for current customers"
    columns = %w[event_id status completed_at gateway customer_id].map(&:to_sym)
    @event.customers.pluck(:id).each { |id| @values << [@event.id, "completed", Time.zone.now, "paypal", id] }
    Order.import columns, @values, validate: false

    @values = []
    credit_id = @event.credit.id
    columns = %w[order_id catalog_item_id amount total redeemed counter].map(&:to_sym)
    @event.reload.orders.pluck(:id).each do |order|
      total = rand(100)
      @values << [order, credit_id, total, total, true, 1]
    end
    OrderItem.import columns, @values, validate: false
    Rails.logger.info "DONE"
  end
end
