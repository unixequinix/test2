class Transactions::Base < ApplicationJob
  SEARCH_ATTS = %i[event_id device_uid device_db_index device_created_at_fixed].freeze

  def perform(atts)
    atts = preformat_atts(atts.symbolize_keys)
    klass = Transaction.class_for_type(atts[:type])
    atts[:type] = klass.to_s

    gtag = create_gtag(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id]) if atts[:customer_tag_uid].present?
    atts[:gtag_id] = gtag&.id
    atts[:customer_id] = gtag&.customer_id

    begin
      transaction = klass.find_or_initialize_by(atts.slice(*SEARCH_ATTS))

      return unless transaction.new_record?
      transaction.update!(column_attributes(klass, atts))

      return if transaction.status_not_ok?
      EventStatsChannel.broadcast_to(Event.find(atts[:event_id]), data: transaction)
      execute_operations(atts.merge(transaction_id: transaction.id))
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def execute_operations(atts)
    load_classes if Rails.env.development?
    children = self.class.descendants
    children.each { |klass| klass.perform_later(atts) if klass::TRIGGERS.include? atts[:action] }
  end

  def column_attributes(klass, atts)
    atts.slice(*klass.column_names.compact.map(&:to_sym))
  end

  def preformat_atts(atts)
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

  def create_gtag(atts)
    begin
      gtag = Gtag.find_or_create_by(atts)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    return gtag if gtag.customer.present?
    gtag.update!(customer: Customer.create!(event_id: atts[:event_id]))
    gtag
  end

  # This method is only for development since eager-loading messes up the inherited hook
  def load_classes
    Transactions::Credential::TicketChecker.inspect
    Transactions::Credential::GtagReplacer.inspect
    Transactions::Credential::TicketChecker.inspect
    Transactions::Credit::BalanceUpdater.inspect
    Transactions::Operator::PermissionCreator.inspect
    Transactions::Order::OrderRedeemer.inspect
    Transactions::Stats::FeeCreator.inspect
    Transactions::Stats::SaleCreator.inspect
    Transactions::Stats::TopupCreator.inspect
  end

  def permitted_params
    params.require(:company).permit(:name, :event_id)
  end
end
