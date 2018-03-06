class AdmissionsPolicy < ApplicationPolicy
  def index?
    admin_or_promoter
  end
end
