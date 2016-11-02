class UniteTransactions < ActiveRecord::Migration
  def change
    drop_table :transactions if ActiveRecord::Base.connection.table_exists? :transactions
    create_table :transactions do |t|
      t.references  :event, index: true
      t.references  :owner, polymorphic: true, index: true
      t.string   :type
      t.string   :transaction_origin
      t.string   :transaction_category
      t.string   :transaction_type
      t.string   :customer_tag_uid
      t.string   :operator_tag_uid
      t.references  :station, index: true
      t.string   :device_uid
      t.integer  :device_db_index
      t.string   :device_created_at
      t.string   :device_created_at_fixed
      t.integer  :gtag_counter
      t.integer  :counter
      t.integer  :activation_counter
      t.string   :status_message
      t.integer  :status_code
      t.integer  :customer_order_id
      t.references  :access, index: true
      t.integer  :direction
      t.string   :final_access_value
      t.string   :reason
      t.string   :ticket_code
      t.float    :credits
      t.float    :refundable_credits
      t.float    :final_balance
      t.float    :final_refundable_balance
      t.string   :initialization_type
      t.integer  :number_of_transactions
      t.references  :catalogable, polymorphic: true, index: true
      t.float    :items_amount
      t.float    :price
      t.string   :payment_method
      t.string   :payment_gateway
      t.timestamps null: false

      t.references  :profile
      t.references  :ticket
      t.integer :old_id
      t.float :credit_value
      t.integer :operator_activation_counter
    end


    sql = "
INSERT INTO transactions (event_id, owner_id, owner_type, type, transaction_origin, transaction_category, transaction_type, customer_tag_uid, operator_tag_uid, station_id, device_uid, device_db_index, device_created_at, device_created_at_fixed, gtag_counter, counter, activation_counter, status_message, status_code, customer_order_id, access_id, direction, final_access_value, reason, ticket_code, credits, refundable_credits, final_balance, final_refundable_balance, initialization_type, number_of_transactions, catalogable_id, catalogable_type, items_amount, price, payment_method, payment_gateway, created_at, updated_at, profile_id, ticket_id, old_id, credit_value, operator_activation_counter)
SELECT
  event_id,
  NULL,
  NULL,
  'CreditTransaction',
  transaction_origin,
  transaction_category,
  transaction_type,
  customer_tag_uid,
  operator_tag_uid,
  station_id,
  device_uid,
  device_db_index,
  device_created_at,
  device_created_at_fixed,
  gtag_counter,
  counter,
  activation_counter,
  status_message,
  status_code,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  credits,
  refundable_credits,
  final_balance,
  final_refundable_balance,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  created_at,
  updated_at,
  profile_id,
  NULL,
  id,
  credit_value,
  NULL
FROM credit_transactions;

INSERT INTO transactions (event_id, owner_id, owner_type, type, transaction_origin, transaction_category, transaction_type, customer_tag_uid, operator_tag_uid, station_id, device_uid, device_db_index, device_created_at, device_created_at_fixed, gtag_counter, counter, activation_counter, status_message, status_code, customer_order_id, access_id, direction, final_access_value, reason, ticket_code, credits, refundable_credits, final_balance, final_refundable_balance, initialization_type, number_of_transactions, catalogable_id, catalogable_type, items_amount, price, payment_method, payment_gateway, created_at, updated_at, profile_id, ticket_id, old_id, credit_value, operator_activation_counter)
SELECT
  event_id,
  NULL,
  NULL,
  'MoneyTransaction',
  transaction_origin,
  transaction_category,
  transaction_type,
  customer_tag_uid,
  operator_tag_uid,
  station_id,
  device_uid,
  device_db_index,
  device_created_at,
  device_created_at_fixed,
  gtag_counter,
  counter,
  activation_counter,
  status_message,
  status_code,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  catalogable_id,
  catalogable_type,
  items_amount,
  price,
  payment_method,
  payment_gateway,
  created_at,
  updated_at,
  profile_id,
  NULL,
  id,
  NULL,
  NULL
FROM money_transactions;

INSERT INTO transactions (event_id, owner_id, owner_type, type, transaction_origin, transaction_category, transaction_type, customer_tag_uid, operator_tag_uid, station_id, device_uid, device_db_index, device_created_at, device_created_at_fixed, gtag_counter, counter, activation_counter, status_message, status_code, customer_order_id, access_id, direction, final_access_value, reason, ticket_code, credits, refundable_credits, final_balance, final_refundable_balance, initialization_type, number_of_transactions, catalogable_id, catalogable_type, items_amount, price, payment_method, payment_gateway, created_at, updated_at, profile_id, ticket_id, old_id, credit_value, operator_activation_counter)
SELECT
  event_id,
  NULL,
  NULL,
  'DeviceTransaction',
  transaction_origin,
  transaction_category,
  transaction_type,
  customer_tag_uid,
  operator_tag_uid,
  station_id,
  device_uid,
  device_db_index,
  device_created_at,
  device_created_at_fixed,
  gtag_counter,
  counter,
  activation_counter,
  status_message,
  status_code,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  initialization_type,
  number_of_transactions,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  created_at,
  updated_at,
  profile_id,
  NULL,
  id,
  NULL,
  NULL
  FROM device_transactions;

INSERT INTO transactions (event_id, owner_id, owner_type, type, transaction_origin, transaction_category, transaction_type, customer_tag_uid, operator_tag_uid, station_id, device_uid, device_db_index, device_created_at, device_created_at_fixed, gtag_counter, counter, activation_counter, status_message, status_code, customer_order_id, access_id, direction, final_access_value, reason, ticket_code, credits, refundable_credits, final_balance, final_refundable_balance, initialization_type, number_of_transactions, catalogable_id, catalogable_type, items_amount, price, payment_method, payment_gateway, created_at, updated_at, profile_id, ticket_id, old_id, credit_value, operator_activation_counter)
  SELECT
    event_id,
    NULL,
    NULL,
    'OrderTransaction',
    transaction_origin,
    transaction_category,
    transaction_type,
    customer_tag_uid,
    operator_tag_uid,
    station_id,
    device_uid,
    device_db_index,
    device_created_at,
    device_created_at_fixed,
    gtag_counter,
    counter,
    activation_counter,
    status_message,
    status_code,
    customer_order_id,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    catalogable_id,
    catalogable_type,
    NULL,
    NULL,
    NULL,
    NULL,
    created_at,
    updated_at,
    profile_id,
    NULL,
    id,
    NULL,
    NULL
  FROM order_transactions;


INSERT INTO transactions (event_id, owner_id, owner_type, type, transaction_origin, transaction_category, transaction_type, customer_tag_uid, operator_tag_uid, station_id, device_uid, device_db_index, device_created_at, device_created_at_fixed, gtag_counter, counter, activation_counter, status_message, status_code, customer_order_id, access_id, direction, final_access_value, reason, ticket_code, credits, refundable_credits, final_balance, final_refundable_balance, initialization_type, number_of_transactions, catalogable_id, catalogable_type, items_amount, price, payment_method, payment_gateway, created_at, updated_at, profile_id, ticket_id, old_id, credit_value, operator_activation_counter)
  SELECT
    event_id,
    NULL,
    NULL,
    'CredentialTransaction',
    transaction_origin,
    transaction_category,
    transaction_type,
    customer_tag_uid,
    operator_tag_uid,
    station_id,
    device_uid,
    device_db_index,
    device_created_at,
    device_created_at_fixed,
    gtag_counter,
    counter,
    activation_counter,
    status_message,
    status_code,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    ticket_code,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    created_at,
    updated_at,
    profile_id,
    ticket_id,
    id,
    NULL,
    NULL
  FROM credential_transactions;

INSERT INTO transactions (event_id, owner_id, owner_type, type, transaction_origin, transaction_category, transaction_type, customer_tag_uid, operator_tag_uid, station_id, device_uid, device_db_index, device_created_at, device_created_at_fixed, gtag_counter, counter, activation_counter, status_message, status_code, customer_order_id, access_id, direction, final_access_value, reason, ticket_code, credits, refundable_credits, final_balance, final_refundable_balance, initialization_type, number_of_transactions, catalogable_id, catalogable_type, items_amount, price, payment_method, payment_gateway, created_at, updated_at, profile_id, ticket_id, old_id, credit_value, operator_activation_counter)
  SELECT
    event_id,
    NULL,
    NULL,
    'AccessTransaction',
    transaction_origin,
    'access',
    transaction_type,
    customer_tag_uid,
    operator_tag_uid,
    station_id,
    device_uid,
    device_db_index,
    device_created_at,
    device_created_at_fixed,
    gtag_counter,
    counter,
    activation_counter,
    status_message,
    status_code,
    NULL,
    access_id,
    direction,
    final_access_value,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    created_at,
    updated_at,
    profile_id,
    NULL,
    id,
    NULL,
    NULL
  FROM access_transactions;"
    ActiveRecord::Base.connection.execute(sql)


    add_reference :sale_items, :transaction, index: true
    sql = "
    UPDATE sale_items SI
    SET transaction_id = TS.id
    FROM transactions TS
    WHERE  TS.old_id = SI.credit_transaction_id;"
    ActiveRecord::Base.connection.execute(sql)
  end
end
