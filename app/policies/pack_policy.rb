class PackPolicy < ApplicationPolicy
  def clone?
    admin_or_promoter
  end
end
