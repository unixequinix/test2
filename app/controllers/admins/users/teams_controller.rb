class Admins::Users::TeamsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :check_team, only: %i[new create]
  before_action :set_team, except: %i[new create sample_csv]
  before_action :set_devices, only: :show

  def show
    @grouped_devices = @team_devices.group_by(&:serie)
    authorize @team
  end

  def new
    @team = current_user.build_user_team.build_team
    authorize @team
  end

  def create
    @team = current_user.build_user_team.build_team(team_permitted_params)
    @team.user_teams.new(user_id: current_user.id, email: current_user.email, leader: true)
    authorize @team

    respond_to do |format|
      if @team.save
        format.html { redirect_to admins_user_team_path(current_user), notice: t("teams.created") }
        format.json { render :show, status: :created, location: [:admins, current_user, @team] }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @team

    respond_to do |format|
      if @team.update(team_permitted_params)
        format.json { render status: :ok, json: @team }
      else
        format.json { render json: @team.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @team

    respond_to do |format|
      if @team.destroy
        format.html { redirect_to admins_user_path(current_user), notice: t("teams.destroyed") }
        format.json { render status: :ok, json: @team }
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: @team.errors.full_messages }
        format.json { render json: @team.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def devices
    authorize(@team)
    @q = @team.devices.ransack(params[:q])
    @devices = @q.result.includes(:events)
    @devices = @devices.page(params[:page])
  end

  def import_devices
    authorize @team

    file = params[:file][:data].tempfile.path
    redirect_to(admins_user_team_path(current_user), alert: t("teams.add_devices.import.not_supplied")) && return unless file.include?("csv")

    CSV.foreach(file, headers: true, col_sep: ";") do |row|
      current_user.team.devices.find_or_create_by(
        mac: row.field("MAC"),
        asset_tracker: row.field("asset_tracker"),
        serie: row.field("serie"),
        serial: row.field("serial")
      )
    end

    respond_to do |format|
      format.html { redirect_to admins_user_team_path(current_user), notice: t("teams.add_users.added") }
      format.json { render status: :ok, json: @team }
    end
  end

  def add_devices
    authorize @team
    @device = Device.find_or_initialize_by(mac: device_permitted_params[:mac])
    @device&.update!(device_permitted_params) if @device.new_record?

    respond_to do |format|
      if @device.team_id.nil? && @device.update(team_id: current_user.team.id)
        format.html { redirect_to admins_user_team_path(current_user), notice: t("teams.add_devices.added") }
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: t("teams.add_devices.already_belong") } if @device.valid?

        format.html { redirect_to admins_user_team_path(current_user), alert: @device.errors.full_messages.to_sentence }
      end
    end
  end

  def remove_devices
    @devices = @team.devices.left_joins(:device_registrations).where(device_registrations: { id: nil })

    authorize @team

    respond_to do |format|
      if @devices.destroy_all
        format.html { redirect_to admins_user_team_path(current_user), notice: t("teams.remove_devices.removed") }
      else
        format.html { redirect_to request.referer, alert: t("teams.remove_devices.failed") }
      end
    end
  end

  def add_users
    authorize @team
    user_team = UserTeam.create(
      team_id: @team.id,
      user_id: User.find_by(email: user_permitted_params[:email])&.id,
      email: user_permitted_params[:email]
    )

    respond_to do |format|
      if @current_user.team.user_teams << user_team
        if user_team.user.present?
          format.html { redirect_to admins_user_team_path(current_user), notice: t("teams.add_users.added") }
        else
          UserMailer.invite_to_team(user_team).deliver_now
          format.html { redirect_to admins_user_team_path(current_user), notice: "Invitation sent to '#{user_permitted_params[:email]}'" }
        end
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: t("teams.add_users.exists") }
      end
    end
  end

  def remove_users
    authorize @team
    user = User.find_by(email: user_permitted_params[:email])

    if current_user.team == user.team && current_user == user
      path = root_path
      message = t("teams.remove_users.current_user")
    elsif current_user.team == user.team
      path = admins_user_team_path(current_user)
      message = t("teams.remove_users.user")
    end

    respond_to do |format|
      if @team.users.destroy(user)
        format.html { redirect_to path, notice: message }
      else
        format.html { redirect_to root_path, alert: 'You should not be here' }
      end
    end
  end

  def change_role
    authorize @team
    user_team = @team.users.find_by(email: user_permitted_params[:email]).user_team

    respond_to do |format|
      if user_team.update(leader: !user_team.leader)
        format.html { redirect_to admins_user_team_path(current_user), notice: t("teams.role_changed") }
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: t("teams.unable_change_role") }
      end
    end
  end

  def sample_csv
    csv_file = CsvExporter.sample(%w[MAC asset_tracker serie serial], [%w[15C3135122 N34 N 01022222012], %w[34SS5C54Q1 D22], %w[95Q16CV331]])

    respond_to { |format| format.csv { send_data(csv_file) } }
  end

  private

  def set_team
    @team = current_user.team
    redirect_to admins_user_path(current_user), alert: t("teams.not_belong") if @team.blank?
  end

  def check_team
    redirect_to admins_user_path(current_user), notice: t("teams.already_belong") if current_user.team.present?
  end

  def set_devices
    @team_devices = @team.devices
    @q = @team_devices.ransack(params[:q])
    @devices = @q.result
  end

  def team_permitted_params
    params.require(:team).permit(:name)
  end

  def device_permitted_params
    params.require(:device).permit(:mac, :asset_tracker, :serie, :serial)
  end

  def user_permitted_params
    params.require(:user).permit(:email)
  end
end
