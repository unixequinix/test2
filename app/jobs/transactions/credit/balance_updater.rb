require 'staccato/adapter/validate'

module Transactions
  class Credit::BalanceUpdater < Transactions::Base
    FEES = %w[initial_fee topup_fee refund_fee gtag_return_fee gtag_deposit_fee].freeze
    TRIGGERS = %w[sale topup refund record_credit sale_refund replacement_topup replacement_refund] + FEES

    queue_as :medium_low

    def perform(transaction, _atts = {})
      transaction.gtag.recalculate_balance
      # Remove instegration absolut-manifesto when event finish
      if transaction.event.id.eql?(266) && transaction.is_a?(CreditTransaction) && transaction.action.eql?('sale')

        sale_item = SaleItem.find_by(credit_transaction_id: transaction.id)
        product = sale_item&.product

        params = {
          document_hostname: (Rails.env.production? ? 'absolutmanifesto.com' : 'testmanifest.com'),
          category: 'Drink',
          action: 'Consumed',
          label: product&.name || 'no-product-available',
          value: 1,
          document_title: transaction.device_created_at,
          user_id: transaction.customer.gtmid
        }

        tracker = Staccato.tracker(Rails.application.secrets.gtm_tracker, Rails.application.secrets.gtm_client, ssl: true)
        hit = tracker.build_event(params)
        hit.add_custom_dimension(1, transaction.customer.gtmid)
        hit.add_custom_dimension(2, 'Glownet')
        hit.track!
      end

      return unless transaction.customer_tag_uid == transaction.operator_tag_uid
      Alert.propagate(transaction.event, transaction, "has the same operator and customer UIDs", :medium)
    end
  end
end
