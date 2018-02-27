class TransactionPolicy < ApplicationPolicy
  def download_raw_transactions?
    index?
  end

  def fix?
    admin_or_promoter && event_open
  end

  def search?
    index?
  end

  def destroy?
    user.admin?
  end
end
