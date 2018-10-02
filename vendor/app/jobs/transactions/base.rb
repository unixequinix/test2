module Transactions
  class Base < ApplicationJob
    SEARCH_ATTS = %i[event_id device_id device_db_index device_created_at_fixed].freeze

    queue_as :critical

    def perform(atts, credit = nil, v_credit = nil)
      begin
        params = preformat_atts(atts, credit, v_credit)
        klass = params[:type].constantize
        transaction = klass.find_or_initialize_by(params.slice(*SEARCH_ATTS))

        return unless transaction.new_record?

        begin
          transaction.update! params.slice(*klass.column_names.compact.map(&:to_sym))
        rescue ActiveRecord::InvalidForeignKey
          transaction.update! params.slice(*klass.column_names.compact.map(&:to_sym)).merge(customer_id: nil)
        end
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      Transactions::PostProcessor.perform_later(transaction)
    end

    def preformat_atts(atts, credit = nil, v_credit = nil)
      params = atts.dup.symbolize_keys
      params[:payments] = preformat_payments(atts[:payments])
      params[:sale_items_attributes].to_a.each { |item| item[:payments] = preformat_payments(item["payments"]) }
      params[:transaction_origin] = "onsite"

      # device_created_at_fixed formatting should go, since data should come in the right format.
      params.delete(:sale_items_attributes) if params[:sale_items_attributes].to_a.empty?
      params[:device_created_at_fixed] = params[:device_created_at].gsub(/(?<hour>[\+,\-][0-9][0-9])(?<minute>[0-9][0-9])/, '\k<hour>:\k<minute>')
      params[:device_created_at] = params[:device_created_at_fixed][0, 19]

      # TODO: Remove this when Zoho stops
      crds = params[:payments][credit] || {}
      credits = crds[:amount].to_f
      final_credit_balance = crds[:final_balance].to_f

      v_crds = params[:payments][v_credit] || {}
      v_credits = v_crds[:amount].to_f
      final_virtual_credit_balance = v_crds[:final_balance].to_f

      params[:credits] = credits + v_credits
      params[:refundable_credits] = credits
      params[:final_balance] = final_credit_balance + final_virtual_credit_balance
      params[:final_refundable_balance] = final_credit_balance

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
