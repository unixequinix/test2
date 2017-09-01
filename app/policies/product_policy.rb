class ProductPolicy < ApplicationPolicy
  def index?
    true
  end

  def sample_csv?
    admin_or_promoter
  end

  def import?
    admin_or_promoter && event_open
  end
end
