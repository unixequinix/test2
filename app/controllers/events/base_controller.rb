class Events::BaseController < ApplicationController
  before_action :fetch_current_event
end