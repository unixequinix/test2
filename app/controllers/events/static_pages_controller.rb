class Events::StaticPagesController < Events::EventsController
  layout "customer"

  skip_before_action :authenticate_customer!
  skip_before_action :check_portal_open

  def privacy_policy
    render_with_locale
  end

  def terms_of_use
    render_with_locale
  end

  private

  def render_with_locale
    locale = I18n.locale || "en"
    render("#{request[:action]}_#{locale}") && return
  end
end
