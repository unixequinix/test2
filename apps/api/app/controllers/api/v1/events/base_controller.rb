class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
end
