class ProductPolicy < ApplicationPolicy
  def sample_csv?
    admin_and_promoter
  end

  def import?
    admin_and_promoter && event_open
  end
end
