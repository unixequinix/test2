class Admins::BaseController < ApplicationController
  before_action :authenticate_admin!
  before_action :fetch_current_event
  layout 'admin'
end
