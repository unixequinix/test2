class Admins::Events::TransactionsController < Admins::Events::BaseController

  def index
    @transactions = current_event.transactions
                                 .includes(:ticket,
                                           :preevent_product,
                                           :station,
                                           :customer_event_profile).group_by(&:type)
  end
end