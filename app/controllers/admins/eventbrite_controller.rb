class Admins::EventbriteController < ApplicationController
  # this method is here because all auth sessions redirect to a common action (this one).
  # this allows to being able to create only one common app in Eventbrite
  def auth
    event = Event.find_by slug: cookies.signed[:event_slug]
    redirect_to(admins_event_path(event), alert: "Access Denied") && return if params[:error]

    uri = URI("https://www.eventbrite.com/oauth/token")
    secret = Rails.application.secrets.eventbrite_client_secret
    client = Rails.application.secrets.eventbrite_client_id

    res = Net::HTTP.post_form(uri, code: params[:code], client_secret: secret, client_id: client, grant_type: "authorization_code")
    token = JSON.parse(res.body)["access_token"]

    event.update! eventbrite_token: token
    redirect_to admins_event_eventbrite_path(event), notice: "Eventbrite login successful"
  end
end
