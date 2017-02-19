# == Schema Information
#
# Table name: devices
#
#  asset_tracker :string
#  device_model  :string
#  imei          :string           indexed => [mac, serial_number]
#  mac           :string           indexed => [imei, serial_number]
#  serial_number :string           indexed => [mac, imei]
#
# Indexes
#
#  index_devices_on_mac_and_imei_and_serial_number  (mac,imei,serial_number) UNIQUE
#

class Device < ActiveRecord::Base
  before_validation :upcase_asset_tracker!

  def self.transactions_count(event) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(cep)))
      FROM (
        SELECT transaction.device_uid, count(transaction.device_uid) as transactions_count,
        (
          SELECT action
          FROM device_transactions
          WHERE device_transactions.device_uid = transaction.device_uid
          AND device_transactions.event_id = #{event.id}
          ORDER BY device_created_at DESC
          LIMIT 1
        ) as action
        FROM (SELECT device_uid FROM device_transactions WHERE device_transactions.event_id = #{event.id}) as transaction
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
    asset_tracker&.upcase!
  end
end
