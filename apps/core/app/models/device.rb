# == Schema Information
#
# Table name: devices
#
#  id            :integer          not null, primary key
#  device_model  :string
#  imei          :string
#  mac           :string
#  serial_number :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  asset_tracker :string
#

class Device < ActiveRecord::Base
  before_validation :upcase_asset_tracker!
  validates :mac, :imei, :serial_number, presence: true

  def self.transactions_count(event) # rubocop:disable Metrics/MethodLength
    query = Transaction::TYPES.map do |type|
      "SELECT device_uid FROM \"#{type}_transactions\" WHERE \"#{type}_transactions\".\"event_id\" = #{event.id}"
    end.join(" UNION ALL ")

    # TODO: This query has been adapted to a missing transaction is not sent from the devices
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(cep)))
      FROM (
        SELECT transaction.device_uid, count(transaction.device_uid) as transactions_count,
        (
          SELECT sum(num_transactions) FROM (
            SELECT
              num_transactions,
              transaction_type
            FROM (
                SELECT
                  number_of_transactions as num_transactions,
                  transaction_type
                FROM device_transactions
                WHERE device_transactions.device_uid = transaction.device_uid
                AND device_transactions.event_id = #{event.id}
                ORDER BY device_created_at DESC
                LIMIT 1
              ) last_transaction
            WHERE transaction_type <> 'pack_device'
            UNION ALL
            SELECT
              sum(number_of_transactions) as num_transactions,
              transaction_type
            FROM device_transactions
            WHERE device_transactions.device_uid = transaction.device_uid
            AND device_transactions.event_id = #{event.id}
            AND device_transactions.transaction_type = 'pack_device'
            GROUP BY number_of_transactions, transaction_type
          ) total_transactions
        ) as device_counter,
        (
          SELECT transaction_type
          FROM device_transactions
          WHERE device_transactions.device_uid = transaction.device_uid
          AND device_transactions.event_id = #{event.id}
          ORDER BY device_created_at DESC
          LIMIT 1
        ) as transaction_type
        FROM (#{query}) as transaction
        GROUP BY device_uid
        ORDER BY device_uid
      ) cep
    SQL
    JSON.parse(ActiveRecord::Base.connection.select_value(sql))
  end

  def upcase_asset_tracker!
    asset_tracker.upcase! if asset_tracker
  end
end
