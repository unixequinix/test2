module Transactions
  class Base < ApplicationJob
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

      Transactions::PostProcessor.perform_later(transaction, params.slice(:customer_id, :role, :group, :station_permission_id))
    end

    def preformat_atts(atts)
      params = atts.dup.symbolize_keys
      params[:payments] = preformat_payments(atts[:payments])
      params[:sale_items_attributes].to_a.each { |item| item[:payments] = preformat_payments(item["payments"]) }
      params[:transaction_origin] = Transaction::ORIGINS[:device]

      # device_created_at_fixed formatting should go, since data should come in the right format.
      params.delete(:sale_items_attributes) if params[:sale_items_attributes].to_a.empty?
      params[:device_created_at_fixed] = params[:device_created_at].gsub(/(?<hour>[\+,\-][0-9][0-9])(?<minute>[0-9][0-9])/, '\k<hour>:\k<minute>')
      params[:device_created_at] = params[:device_created_at_fixed][0, 19]
      params
    end

    def preformat_payments(payments)
      slice_atts = %i[amount final_balance unit_price credit_name credit_value total_price]
      payments.to_a.map!(&:symbolize_keys).map { |pay| [pay[:credit_id], pay.slice(*slice_atts)] }.to_h
    end

    def self.inherited(klass)
      @descendants ||= []
      @descendants << klass
    end

    def self.descendants
      @descendants || []
    end
  end
end
