class CreateCustomerCredits < ActiveRecord::Migration
  def change
    create_table :customer_credits do |t|
      t.references :customer_event_profile, null: false
      t.decimal :amount, null: false
      t.decimal :refundable_amount, null: false
      t.decimal :final_balance, null: false
      t.decimal :final_refundable_balance, null: false
      t.decimal :value_credit, null: false
      t.string :payment_method, null: false
      t.string :transaction_source, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    migrate_credit_logs
  end

  def migrate_credit_logs
    CustomerEventProfile.all.each do |customer_event_profile|
      customer_event_profile.credit_logs.each do |credit_log|
        CustomerCreditCreator.new(
          amount: credit_log.amount,
          refundable_amount: credit_log.amount,
          transaction_source: credit_log.transaction_type,
          payment_method: "none",
          customer_event_profile: customer_event_profile
        ).save if credit_log.amount != 0
      end
      gtag_credit_log = load_gtag_credit_log(customer_event_profile)
      if gtag_credit_log
        last_customer_credit = load_last_customer_credit(customer_event_profile)
        CustomerCredit.create(
          amount: gtag_credit_log.amount - last_customer_credit.amount,
          refundable_amount: gtag_credit_log.amount - last_customer_credit.amount,
          final_balance: gtag_credit_log.amount,
          final_refundable_balance: gtag_credit_log.amount,
          transaction_source: credit_log.transaction_type,
          payment_method: "none",
          customer_event_profile: customer_event_profile
        )
      end
    end
  end

  def load_gtag_credit_log(customer_event_profile)
    gtag_credit_log = GtagCreditLog.joins(gtag: :customer_event_profiles)
      .where(gtag: [customer_event_profile: customer_event_profile])[0]
  end

  def load_last_customer_credit(customer_event_profile)
    CustomerCredit.order(created_at: :desc)
      .where(customer_event_profile: customer_event_profile)[0]
  end
end
