class Device < ActiveRecord::Base
  before_validation :upcase_asset_tracker!

  def self.transactions_count(event) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(cep)))
      FROM (
        SELECT transaction.device_uid, count(transaction.device_uid) as transactions_count,
        (
          SELECT type
          FROM transactions
          WHERE transactions.device_uid = transaction.device_uid
          AND transactions.event_id = #{event.id}
          AND transactions.type = 'DeviceTransaction'
          ORDER BY device_created_at DESC
          LIMIT 1
        ) as transaction_type
        FROM (SELECT device_uid FROM transactions WHERE transactions.event_id = #{event.id}) as transaction
        GROUP BY device_uid
        ORDER BY device_uid
      ) cep
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    JSON.parse(sql)
  end

  def upcase_asset_tracker!
    asset_tracker.upcase! if asset_tracker
  end
end
