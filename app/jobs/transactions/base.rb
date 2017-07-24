class Transactions::Base < ApplicationJob
  SEARCH_ATTS = %i[event_id device_uid device_db_index device_created_at_fixed].freeze

  def perform(atts)
    atts = preformat_atts(atts.symbolize_keys)
    klass = Transaction.class_for_type(atts[:type])
    atts[:type] = klass.to_s

    gtag = create_gtag(atts[:customer_tag_uid], atts[:event_id])
    atts[:gtag_id] = gtag&.id

    begin
      transaction = klass.find_or_initialize_by(atts.slice(*SEARCH_ATTS))

      # If transaction is not new_record, it means we have it from before, so we stop here.
      return unless transaction.new_record?

      # if it is new, at least we have to save it
      atts[:customer_id] = apply_customers(atts[:event_id], atts[:customer_id], gtag) if gtag
      transaction.update!(column_attributes(klass, atts))

      # only execute operations of good transactions. Other status dont trigger operations
      return if transaction.status_not_ok?

      execute_operations(atts.merge(transaction_id: transaction.id))
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def execute_operations(atts)
    children = self.class.descendants
    children.each { |klass| klass.perform_later(atts) if klass::TRIGGERS.include? atts[:action] }
  end

  def column_attributes(klass, atts)
    atts.slice(*klass.column_names.compact.map(&:to_sym))
  end

  def preformat_atts(atts)
    # this should slowly go, since data should come in the right format.
    atts[:transaction_origin] = Transaction::ORIGINS[:device]
    atts[:station_id] = Station.find_by(event_id: atts[:event_id], station_event_id: atts[:station_id])&.id
    atts[:order_item_counter] = atts[:order_item_id] if atts.key?(:order_item_id)
    atts[:device_created_at_fixed] = atts[:device_created_at].gsub(/(?<hour>[\+,\-][0-9][0-9])(?<minute>[0-9][0-9])/, '\k<hour>:\k<minute>')
    atts[:device_created_at] = atts[:device_created_at_fixed][0, 19]
    atts.delete(:sale_items_attributes) if atts[:sale_items_attributes].blank?
    atts
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass
  end

  def self.descendants
    @descendants || []
  end

  private

  def apply_customers(event_id, customer_id, gtag)
    # We try and claim first because we want to succeed-fast in case transaction comes with customer_id and gtag too (check_in & order_redeemed)
    claimed = Customer.claim(event_id, customer_id, gtag.customer_id)
    return customer_id if claimed.present?

    # We first try to assign the transactions customer
    if customer_id.present?
      gtag.update!(customer_id: customer_id)
      return customer_id
    end

    # the gtag has a customer but the transaction doesnt. We dont create another customer

    # second, the gtag has no customer, the transaction neither, this is only time we create anonymous customer
    if gtag.customer_id.blank?
      gtag.update!(customer: Customer.create!(event_id: event_id, anonymous: true))
    end

    # finally, the transaction has no customer, the gtag already has a customer, this means its a sale before a check_in or order_redeemed.
    gtag.customer_id
  end

  def create_gtag(tag_uid, event_id)
    # ticket_activation transactions dont have tag_uid
    return unless tag_uid

    Gtag.find_or_create_by(tag_uid: tag_uid, event_id: event_id)
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def permitted_params
    params.require(:company).permit(:name, :event_id)
  end
end
