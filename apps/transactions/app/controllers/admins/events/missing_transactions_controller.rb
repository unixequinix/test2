class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    @devices = current_event.device_transactions.order(device_created_at: :asc).group_by(&:device_uid).select do |_, ts|
      ts.last.transaction_type != "pack_device"
    end
  end
end
