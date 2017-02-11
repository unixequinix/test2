class CompanyPolicy < ApplicationPolicy
  def visibility?
    admin_and_promoter
  end
end
