class Transactions::Base < ApplicationJob
  Dir[Rails.root.join('apps', 'jobs', 'transactions', '*.rb')].each { |file| require file }

  SEARCH_ATTS = %i[event_id device_uid device_db_index device_created_at_fixed].freeze

  queue_as :default

  def perform(atts)
    begin
      params = preformat_atts(atts)
      klass = params[:type].constantize
      transaction = klass.find_or_initialize_by(params.slice(*SEARCH_ATTS))

      return unless transaction.new_record?
      transaction.update! params.slice(*klass.column_names.compact.map(&:to_sym))
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    Transactions::PostProcessor.perform_later(params.merge(transaction_id: transaction.id))
  end

  def preformat_atts(atts)
    params = atts.dup.symbolize_keys
    # this should slowly go, since data should come in the right format.
    params[:type] = Transaction.class_for_type(params[:type]).to_s
    params[:transaction_origin] = Transaction::ORIGINS[:device]
    params[:station_id] = Station.find_by(event_id: params[:event_id], station_event_id: params[:station_id])&.id if params[:station_id]
    params[:station_id] = params[:real_station_id] if params[:real_station_id]
    params[:order_item_counter] = params[:order_item_id] if params.key?(:order_item_id)
    params[:device_created_at_fixed] = params[:device_created_at].gsub(/(?<hour>[\+,\-][0-9][0-9])(?<minute>[0-9][0-9])/, '\k<hour>:\k<minute>')
    params[:device_created_at] = params[:device_created_at_fixed][0, 19]
    params.delete(:sale_items_attributes) if params[:sale_items_attributes].blank?
    params
  end

  def self.execute_descendants(atts)
    descendants.each { |klass| klass.perform_later(atts) if klass::TRIGGERS.include? atts[:action] }
    Stats::Base.execute_descendants(atts[:transaction_id], atts[:action])
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass
  end

  def self.descendants
    @descendants || []
  end
end
