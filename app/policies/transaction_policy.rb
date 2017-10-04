class TransactionPolicy < ApplicationPolicy
  def download_raw_transactions?
    index?
  end

  def fix?
    admin_or_promoter && event_open
  end

  def status_9?
    admin_or_promoter && event_open
  end

  def status_0?
    admin_or_promoter && event_open
  end

  def search?
    index?
  end

  def destroy?
    user.admin?
  end
end
