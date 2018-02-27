module Admins
  module Users
    class TeamsController < Admins::BaseController
      before_action :check_team, only: %i[new create]
      before_action :set_team, except: %i[new create sample_csv]
      before_action :set_devices, only: :show

      def show
        @grouped_devices = @team_devices.group_by(&:serie)
        @device = Device.new(team: @team)
        authorize @team
      end

      def new
        @team = current_user.build_active_team_invitation.build_team
        authorize @team
      end

      def create
        @team = current_user.build_active_team_invitation.build_team(team_permitted_params)
        @team.team_invitations.new(user_id: current_user.id, email: current_user.email, leader: true, active: true)
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

      def add_users
        authorize @team
        team_invitation = TeamInvitation.create(
          team_id: @team.id,
          user_id: User.find_by(email: user_permitted_params[:email])&.id,
          email: user_permitted_params[:email],
          active: false
        )

        respond_to do |format|
          if team_invitation.user.present?
            if team_invitation.user.team.nil?
              @current_user.team.team_invitations << team_invitation
              UserMailer.invite_to_team_user(team_invitation).deliver_now
              format.html { redirect_to admins_user_team_path(current_user), notice: "Invitation sent to '#{user_permitted_params[:email]}'" }
            else
              UserMailer.invite_to_team_user(team_invitation).deliver_now
              format.html { redirect_to admins_user_team_path(current_user), alert: t("teams.add_users.exists"), notice: " Invitation sent" }
            end
          else
            @current_user.team.team_invitations << team_invitation
            UserMailer.invite_to_team(team_invitation).deliver_now
            format.html { redirect_to admins_user_team_path(current_user), notice: "Invitation sent to '#{user_permitted_params[:email]}'" }
          end
        end
      end

      def remove_users # rubocop:disable Metrics/PerceivedComplexity
        authorize @team
        team_invitation = @team.users.find_by(email: user_permitted_params[:email]).team_invitations.first

        user = User.find_by(email: user_permitted_params[:email])

        if current_user.team == user.team && current_user == user
          path = root_path
          message = t("teams.remove_users.current_user")
        elsif current_user.team == user.team
          path = admins_user_team_path(current_user)
          message = t("teams.remove_users.user")
        end

        respond_to do |format|
          if @team.team_invitations.destroy(team_invitation)
            @team.team_invitations.order(:created_at).first.update(leader: true) if @team.team_invitations.leader.none?
            format.html { redirect_to path, notice: message }
          else
            format.html { redirect_to path, alert: 'You should not be here' }
          end
        end
      end

      def change_role
        authorize @team
        team_invitation = @team.users.find_by(email: user_permitted_params[:email]).team_invitations.first

        respond_to do |format|
          if team_invitation.update(leader: !team_invitation.leader)
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
  end
end
