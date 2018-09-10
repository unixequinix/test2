require 'rails_helper'

RSpec.describe Admins::Users::TeamsController, type: :controller do
  let(:team_valid_attributes) do
    { name: "team1" }
  end

  let(:team_invalid_attributes) do
    { name: nil }
  end

  let(:device_valid_attributes) do
    { mac: '007', serie: 'Bond' }
  end

  let(:user_valid_attributes) do
    { email: create(:user).email }
  end

  let(:user_invalid_attributes) do
    { email: 'fake_email' }
  end

  let(:user) { create(:user) }

  describe "GET #show" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        get :show, params: { user_id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirects to user profile path" do
          get :show, params: { user_id: user.id }
          expect(response).to redirect_to(admins_user_path(user.id))
          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to include(I18n.t("teams.not_belong"))
        end
      end

      context "user belongs to a team" do
        before do
          create(:team, leader: user)
        end

        it "returns a success response" do
          get :show, params: { user_id: user.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "GET #new" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        get :new, params: { user_id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "returns a success response" do
          get :new, params: { user_id: user.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context "user belongs to a team" do
        before do
          create(:team, leader: user)
        end

        it "redirects to user team path" do
          get :new, params: { user_id: user.id }
          expect(response).to redirect_to(admins_user_path(user.id))
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to include(I18n.t("teams.already_belong"))
        end
      end
    end
  end

  describe "POST #create" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        post :create, params: { user_id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirect to admins user team path on success" do
          post :create, params: { user_id: user.id, team: team_valid_attributes }
          expect(response).to redirect_to(admins_user_team_path(user))
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to include(I18n.t("teams.created"))
        end

        it "should create a new team record" do
          expect { post :create, params: { user_id: user.id, team: team_valid_attributes } }.to change(Team, :count).by(1)
        end

        it "should create a new team record with associated current_user as user team" do
          expect { post :create, params: { user_id: user.id, team: team_valid_attributes } }.to change(TeamInvitation, :count).by(1)
        end

        it "should not create a new team record" do
          expect { post :create, params: { user_id: user.id, team: team_invalid_attributes } }.to change(Team, :count).by(0)
        end
      end

      context "user belongs to a team" do
        before do
          create(:team, leader: user)
        end

        it "redirects to user team path" do
          post :create, params: { user_id: user.id, team: team_valid_attributes }
          expect(response).to redirect_to(admins_user_path(user.id))
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to include(I18n.t("teams.already_belong"))
        end
      end
    end
  end

  describe "PUT #update" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        put :update, params: { user_id: user.id, team: team_valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirect to admins user path on success" do
          put :update, params: { user_id: user.id, user: { email: user.email }, team: { name: 'new team name' } }, format: :json
          expect(response).to redirect_to(admins_user_path(user))
        end
      end

      context "user belongs to a team" do
        before do
          @team = create(:team, leader: user)
        end

        it "updates successfully" do
          put :update, params: { user_id: user.id, user: { email: user.email }, team: { name: 'new team name' } }, format: :json
          expect(@team.reload.name).to eq('new team name')
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        delete :destroy, params: { user_id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirect to admins user path on success" do
          delete :destroy, params: { user_id: user.id }
          expect(response).to redirect_to(admins_user_path(user))
          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to include(I18n.t("teams.not_belong"))
        end
      end

      context "user belongs to a team" do
        before do
          create(:team, leader: user)
        end

        it "destroys successfully if user is not the last" do
          expect { delete :destroy, params: { user_id: user.id } }.to change(Team, :count).by(-1) unless user.team.users.one?
        end

        it "does not destroy the user if its last" do
          expect { delete :destroy, params: { user_id: user.id } }.not_to change(Team, :count) if user.team.users.one?
        end
      end
    end
  end

  describe "POST #add_users" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        post :add_users, params: { user_id: user.id, user: device_valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirect to admins user path on success" do
          post :add_users, params: { user_id: user.id, user: user_valid_attributes }
          expect(response).to redirect_to(admins_user_path(user))
          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to include(I18n.t("teams.not_belong"))
        end

        it "should not create a new device record on team" do
          expect { post :add_users, params: { user_id: user.id, user: user_invalid_attributes } }.to change(TeamInvitation, :count).by(0)
        end
      end

      context "user belongs to a team" do
        before do
          create(:team, leader: user)
        end

        context "added user is not registered" do
          it "create user team without confirmed user" do
            expect { post :add_users, params: { user_id: user.id, user: { email: create(:user, email: 'fake@email.com').email } } }.to change(TeamInvitation, :count).by(1)
          end

          it "send email to unregistered user" do
            expect do
              post :add_users, params: { user_id: user.id, user: { email: 'fake@email.com' } }
            end.to change(ActionMailer::Base.deliveries, :count).by(1)
          end
        end

        it "redirects to user team path" do
          post :add_users, params: { user_id: user.id, user: user_valid_attributes }
          expect(response).to redirect_to(admins_user_team_path(user.id))
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to include("Invitation sent to '#{User.last[:email]}'")
        end

        it "should not create a new device record on team if user is not leader" do
          user.team_invitations.first.update(leader: false)

          expect { post :add_users, params: { user_id: user.id, user: user_valid_attributes } }.to change(TeamInvitation, :count).by(0)
        end

        it "should create a new device record on team if user is leader" do
          expect { post :add_users, params: { user_id: user.id, user: user_valid_attributes } }.to change(TeamInvitation, :count).by(1)
        end
      end
    end
  end

  describe "DELETE #remove_users" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        delete :remove_users, params: { user_id: user.id, user: user_valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirect to admins user path on success" do
          delete :remove_users, params: { user_id: user.id, user: user_valid_attributes }
          expect(response).to redirect_to(admins_user_path(user))
          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to include(I18n.t("teams.not_belong"))
        end

        it "should not destroy user team if user does not belong to team" do
          create(:team_invitation, team: create(:team), user: User.find_by(user_valid_attributes), leader: true)
          expect { delete :remove_users, params: { user_id: user.id, user: user_valid_attributes } }.to change(TeamInvitation, :count).by(0)
        end
      end

      context "user belongs to a team" do
        before do
          @team = create(:team, leader: user)
        end

        context "available delete users from team" do
          before do
            @guest_user = create(:user)
            create(:team_invitation, user: @guest_user, team: @team, active: true)
          end

          it "redirects to root path if deleted user is current user" do
            delete :remove_users, params: { user_id: user.id, user: { email: user.email } }
            expect(response).to redirect_to(root_path)
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to include(I18n.t("teams.remove_users.current_user"))
          end

          it "should destroy user team record from team" do
            expect { delete :remove_users, params: { user_id: user.id, user: { email: user.email } } }.to change(TeamInvitation, :count).by(-1)
          end

          it "redirects to user team path if deleted user is not current user" do
            delete :remove_users, params: { user_id: user.id, user: { email: @guest_user.email } }
            expect(response).to redirect_to(admins_user_team_path(user))
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to include(I18n.t("teams.remove_users.user"))
          end

          it "should destroy user team record from team" do
            expect { delete :remove_users, params: { user_id: user.id, user: { email: @guest_user.email } } }.to change(TeamInvitation, :count).by(-1)
          end

          it "is not authorize to do that action" do
            user.team_invitations.first.update(leader: false)
            delete :remove_users, params: { user_id: user.id, user: { email: @guest_user.email } }
            expect do
              Pundit.authorize(user, user.team, :remove_users?)
            end.to raise_error(Pundit::NotAuthorizedError)
          end
        end

        it "should not destroy user team record from team if it the last one" do
          expect { delete :remove_users, params: { user_id: user.id, user: { email: user.email } } }.to change(TeamInvitation, :count).by(0)
          expect(flash[:error]).to be_present
          expect(flash[:error]).to include("You are not authorized to perform this action")
        end
      end
    end
  end

  describe "PUT #change_role" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        put :change_role, params: { user_id: user.id, team: team_valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      context "user does not belong to any team" do
        it "redirect to admins user path on success" do
          put :change_role, params: { user_id: user.id, user: user_valid_attributes }
          expect(response).to redirect_to(admins_user_path(user))
        end
      end

      context "user belongs to a team and is a leader" do
        before do
          @team = create(:team, leader: user)
          @team_inv = create(:team_invitation, team: @team, user: User.find_by(user_valid_attributes), leader: false, active: true)
        end

        it "updates role successfully" do
          put :change_role, params: { user_id: user.id, user: user_valid_attributes }
          expect(@team_inv.reload.leader).to eq(true)
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to include(I18n.t("teams.role_changed"))
        end
      end

      context "user belongs to a team and is not a leader" do
        before do
          @team = create(:team)
          create(:team_invitation, team: @team, user: user, leader: false)
          @team_inv = create(:team_invitation, team: @team, user: User.find_by(user_valid_attributes), leader: false)
        end

        it "updates role is not allowed" do
          put :change_role, params: { user_id: user.id, user: user_valid_attributes }
          expect(@team_inv.reload.leader).to eq(false)
        end
      end
    end
  end
end
