class Admins::Users::TeamsController < ApplicationController # rubocop:disable Metrics/ClassLength
  layout 'admin'

  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :check_team, only: %i[new create]
  before_action :set_team, except: %i[new create sample_csv]
  before_action :set_devices, only: :show

  after_action :verify_authorized # disable not to raise exception when action does not have authorize method

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
    @team.user_teams.new(user_id: current_user.id, leader: true)
    authorize @team

    respond_to do |format|
      if @team.save
        format.html { redirect_to admins_user_team_path(current_user), notice: 'Team was successfully created.' }
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
        format.html { redirect_to admins_user_path(current_user), notice: 'Team destroyed' }
        format.json { render status: :ok, json: @team }
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: @team.errors.full_messages }
        format.json { render json: @team.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def import_devices
    authorize @team

    file = params[:file][:data].tempfile.path
    redirect_to(admins_user_team_path(current_user), alert: "File not supplied") && return unless file.include?("csv")

    CSV.foreach(file, headers: true, col_sep: ";") do |row|
      current_user.team.devices.find_or_create_by(
        mac: row.field("MAC"),
        asset_tracker: row.field("asset_tracker"),
        serie: row.field("serie"),
        serial: row.field("serial")
      )
    end

    respond_to do |format|
      format.html { redirect_to admins_user_team_path(current_user), notice: 'Devices added' }
      format.json { render status: :ok, json: @team }
    end
  end

  def add_devices
    authorize @team

    params = {}
    device_permitted_params[:asset_tracker].blank? ? params : params[:asset_tracker] = device_permitted_params[:asset_tracker]
    device_permitted_params[:mac].blank? ? params : params[:mac] = device_permitted_params[:mac]

    @device = Device.find_or_create_by(params)
    @device.update(team_id: current_user.team.id) if @device.team_id.nil?

    respond_to do |format|
      if @device.save
        format.html { redirect_to admins_user_team_path(current_user), notice: 'Device added.' }
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: 'Device is already part of a team.' }
      end
    end
  end

  def remove_devices
    @devices = @team.devices.left_joins(:device_registrations).where(device_registrations: { id: nil })

    authorize @team

    respond_to do |format|
      if @devices.destroy_all
        format.html { redirect_to admins_user_team_path(current_user), notice: 'Devices removed.' }
      else
        format.html { redirect_to request.referer, alert: 'Something went wrong.' }
      end
    end
  end

  def add_users
    authorize @team
    user = User.find_by(email: user_permitted_params[:email])

    message = if user.present? && user.team.blank?
                'User added to team'
              else
                'User already belongs to a team'
              end

    respond_to do |format|
      if user.present? && current_user.team.users << user
        format.html { redirect_to admins_user_team_path(current_user), notice: message }
      else
        format.html { redirect_to admins_user_team_path(current_user), alert: message }
      end
    end
  end

  def remove_users
    authorize @team
    user = User.find_by(email: user_permitted_params[:email])

    if current_user.team == user.team && current_user == user
      path = root_path
      message = 'You have been removed successfully from team'
    elsif current_user.team == user.team
      path = admins_user_team_path(current_user)
      message = 'User has been removed successfully from team'
    else
      path = root_path
      message = 'User does not belong to this team'
    end

    respond_to do |format|
      if @team.users.destroy(user)
        format.html { redirect_to path, notice: message }
      else
        format.html { redirect_to root_path, alert: 'You should not be here' }
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
    redirect_to admins_user_path(current_user), alert: 'You do not belong to any team' if @team.blank?
  end

  def check_team
    redirect_to admins_user_path(current_user), notice: 'You already belong to a team' if current_user.team.present?
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
    params.require(:device).permit(:mac, :asset_tracker, :serie)
  end

  def user_permitted_params
    params.require(:user).permit(:email)
  end
end
