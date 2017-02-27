class TransactionPolicy < ApplicationPolicy
  def fix?
    admin_and_promoter && event_open
  end

  def status_9?
    admin_and_promoter && event_open
  end

  def status_0?
    admin_and_promoter && event_open
  end

  def search?
    admin_promoter_and_support
  end
end
