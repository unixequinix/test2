class Admins::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :fetch_current_event
end
