class TeamPolicy < ApplicationPolicy
  def devices?
    check_user_team
  end

  def show?
    check_user_team
  end

  def new?
    user.team.blank?
  end

  def create?
    user.team.blank?
  end

  def update?
    leader_or_admin
  end

  def destroy?
    leader_or_admin
  end

  def add_users?
    leader_or_admin
  end

  def remove_users?
    check_user_team && user.team_leader? && record.users.count > 1 || user.admin?
  end

  def remove_devices?
    leader_or_admin
  end

  def import_devices?
    check_user_team || user.admin?
  end

  def sample_csv?
    admin_or_promoter
  end

  def set_team?
    user&.team.present?
  end

  def change_role?
    leader_or_admin
  end

  private

  def leader_or_admin
    check_user_team && user.team_leader? || user.admin?
  end

  def check_user_team
    user.team.present? && user.team == record
  end
end
