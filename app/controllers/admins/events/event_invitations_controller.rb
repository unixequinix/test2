module Admins
  module Events
    class EventInvitationsController < Admins::Events::BaseController
      before_action :set_invitation, only: %i[resend destroy accept]

      def create
        email = permitted_params[:email]
        user = User.find_by(email: email)
        authorize @current_event
        if !@current_event.users.map(&:email).include?(email)
          @invitation = @current_event.event_invitations.new(permitted_params)
          authorize(@invitation)
          if @invitation.save
            UserMailer.invite_to_event(@invitation, user.present?).deliver_now
            redirect_to admins_event_event_registrations_path, notice: "Invitation sent to '#{email}', when accepted, it will be added to your users"
          else
            redirect_to admins_event_event_registrations_path, alert: "Ups! Impossible to send the invitation"
          end
        else
          redirect_to admins_event_event_registrations_path, alert: "Ups! This user is currently active in the event"
        end
      end

      def update
        respond_to do |format|
          if @invitation.update(permitted_params)
            format.html { redirect_to admins_event_event_registrations_path, notice: t("alerts.updated") }
            format.json { render json: @invitation }
          else
            flash.now[:alert] = t("alerts.error")
            format.html { render :edit }
            format.json { render json: @invitation.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def resend
        user = User.find_by(email: @invitation.email)
        UserMailer.invite_to_event(@invitation, user.present?).deliver_now
        redirect_to admins_event_event_registrations_path, notice: "Invitation sent to '#{@invitation.email}'"
      end

      def destroy
        respond_to do |format|
          if @invitation.destroy
            format.html { redirect_to request.referer, notice: t("alerts.destroyed") }
            format.json { render json: true }
          else
            format.html { redirect_to admins_event_event_registrations_path, alert: @invitation.errors.full_messages.to_sentence }
            format.json { render json: { errors: @invitation.errors }, status: :unprocessable_entity }
          end
        end
      end

      # Just for registered users invitations
      def accept
        user = User.find_by(email: @invitation.email)
        if current_user == user
          @invitation.accept!(user.id)
          flash[:notice] = "Invitation accepted!"
          redirect_to admins_events_path
        else
          redirect_to admins_event_event_registrations_path, alert: "Ups! Action not allowed for this user."
        end
      end

      private

      def set_invitation
        @invitation = @current_event.event_invitations.find(params[:id])
        authorize @invitation
      end

      def permitted_params
        params.require(:event_invitation).permit(:email, :role)
      end
    end
  end
end
