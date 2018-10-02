module Admins
  module Users
    class TeamsController < Admins::BaseController
      before_action :check_team, only: %i[new create]
      before_action :set_team, except: %i[new create move_devices update_devices]
      before_action :set_teams, only: %i[move_devices update_devices]
      before_action :set_devices, only: :show
      before_action only: %i[move_devices update_devices] do
        persist_query(%i[d d2], false)
      end

      def show
        @grouped_devices = @team_devices.group_by(&:serie).sort_by { |serie, _| serie.to_s }
        @device = Device.new(team: @team)
        @users = @team.users.includes(:active_team_invitation)
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
        @d = @team.devices.ransack(params[:d])
        @devices = @d.result.includes(:events)
        @devices = @devices.page(params[:page])
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

      def remove_users
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

      def remove_devices
        @devices = @team.devices.left_joins(:device_registrations, :device_transactions).where(device_registrations: { id: nil }, device_transactions: { id: nil })
        authorize @team

        if @devices.delete_all
          redirect_to admins_user_team_path(current_user), notice: t("teams.remove_devices.removed")
        else
          redirect_to request.referer, alert: t("teams.remove_devices.failed")
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

      def move_devices
        @load_analytics_resources = false
      end

      def update_devices
        dest_team_id = nil
        something_updated = false
        if device_permitted_params[:ids].present?
          Device.where(id: device_permitted_params[:ids]).each do |d|
            dest_team_id = params[:device][:destination_team_id].eql?(d.team.id.to_s) ? params[:device][:origin_team_id] : params[:device][:destination_team_id]
            if d.device_registration.blank?
              d.update!(team_id: dest_team_id)
              something_updated = true
            end
          end

          @team = Team.find(([params[:device][:origin_team_id], params[:device][:destination_team_id]] - [dest_team_id]).first)
          @dest_team = Team.find(dest_team_id)

          set_teams

          flash[:notice] = "Devices correctly moved" if something_updated
        else
          flash[:alert] = "Please select any device to move"
        end

        respond_to do |format|
          format.js { render action: 'update_devices' }
        end
      end

      private

      def set_team
        @team = current_user.team
        redirect_to admins_user_path(current_user), alert: t("teams.not_belong") if @team.blank?
      end

      def set_teams
        if params[:device].present?
          origin_team_id = params[:device][:origin_team_id]
          destination_team_id = params[:device][:destination_team_id]
        else
          origin_team_id = persist_query([:d]).try(:[], 'team_id_eq')
          destination_team_id = persist_query([:d2]).try(:[], 'team_id_eq')
        end
        team, destination_team = params[:device][:direction].eql?('right') ? [origin_team_id, destination_team_id] : [destination_team_id, origin_team_id] if params[:device].present?
        @team = params[:d].present? && params[:d][:team_id_eq].present? ? Team.find(params[:d][:team_id_eq]) : Team.find(team || (origin_team_id || current_user.team.id))
        @dest_team = params[:d2].present? && params[:d2][:team_id_eq].present? ? Team.find(params[:d2][:team_id_eq]) : Team.find(destination_team || (destination_team_id || Team.last.id))
        @d = @team.devices.ransack(params[:d]).result.ransack(params[:d_devices])
        @d2 = @dest_team.devices.ransack(params[:d2]).result.ransack(params[:d2_devices])
        @devices = @d.result.includes(:event, :device_registration).page(params[:devicesout]).order('asset_tracker ASC')
        @dest_team_devices = @d2.result.includes(:event, :device_registration).page(params[:devicesin]).order('asset_tracker ASC')
        @teams = Team.all.order(:name)

        authorize @team
      end

      def persist_query(cookie_keys, clear = false)
        cookie_keys.map { |key| cookies.delete(key) } && return if clear

        param = :d if cookie_keys.include?(:d)
        param = :d2 if cookie_keys.include?(:d2)

        cookies[param] = params[param].to_json if params[param]
        params[param].presence || (cookies[param].present? && JSON.parse(cookies[param]))
      end

      def check_team
        redirect_to admins_user_path(current_user), notice: t("teams.already_belong") if current_user.team.present?
      end

      def set_devices
        @team_devices = @team.devices.includes(:event).order(:asset_tracker)
        @s = @team_devices.ransack(params[:s])
        @devices = @s.result.page(params[:page])
      end

      def team_permitted_params
        params.require(:team).permit(:name)
      end

      def device_permitted_params
        params.require(:device).permit(:mac, :asset_tracker, :serie, :serial, :origin_team_id, :destination_team_id, ids: [])
      end

      def user_permitted_params
        params.require(:user).permit(:email)
      end
    end
  end
end
