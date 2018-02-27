class CreatePokes < ActiveRecord::Migration[5.1]
  def change
    create_table :pokes do |t|
      t.string :action, null: false
      t.string :description
      t.references :event, index: true, foreign_key: true, null: false
      t.bigint :operation_id, index: true
      t.string :source
      t.datetime :date
      t.integer :line_counter
      t.integer :gtag_counter
      t.references :device, index: true, foreign_key: true
      t.references :station, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.references :customer_gtag, index: true
      t.references :operator, index: true
      t.references :operator_gtag, index: true
      t.references :credential, polymorphic: true, index: true
      t.references :ticket_type, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.references :product, index: true, foreign_key: true
      t.references :order, index: true, foreign_key: true
      t.references :catalog_item, index: true, foreign_key: true
      t.string :catalog_item_type
      t.integer :sale_item_quantity
      t.decimal :sale_item_unit_price, precision: 10, scale: 2
      t.decimal :sale_item_total_price, precision: 10, scale: 2
      t.decimal :standard_unit_price, precision: 10, scale: 2
      t.decimal :standard_total_price, precision: 10, scale: 2
      t.string :payment_method
      t.decimal :monetary_quantity, precision: 10, scale: 2
      t.decimal :monetary_unit_price, precision: 10, scale: 2
      t.decimal :monetary_total_price, precision: 10, scale: 2
      t.references :credit, polymorphic: true, index: true
      t.string :credit_name
      t.decimal :credit_amount, precision: 10, scale: 2
      t.decimal :final_balance, precision: 10, scale: 2
      t.string :message
      t.integer :priority
      t.boolean :user_flag_value
      t.integer :access_direction
      t.integer :error_code
      t.integer :status_code
    end

    add_column :transactions, :operator_gtag_id, :bigint
    add_column :gtags, :missing_transactions, :boolean, default: false
    add_column :gtags, :inconsistent, :boolean, default: false
  end
end
