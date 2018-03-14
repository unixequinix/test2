class AdmissionsPolicy < ApplicationPolicy
  def index?
    admin_or_promoter
  end

  def show?
    admin_or_promoter
  end

  def merge?
    admin_or_promoter
  end
end
