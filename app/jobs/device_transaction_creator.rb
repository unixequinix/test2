class DeviceTransactionCreator < ActiveJob::Base
  def perform(atts)
    new_atts = atts.slice(:device_created_at_fixed, :device_db_index, :device_uid, :event_id, :status_code, :action)
    transaction = DeviceTransaction.find_or_initialize_by(new_atts.symbolize_keys)
    transaction.update!(atts.slice(*DeviceTransaction.column_names)) if transaction.new_record?
  end
end
