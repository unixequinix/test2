class Events::StaticPagesController < Events::EventsController
  layout "customer"
  skip_before_action :authenticate_customer!
  before_action :render_with_locale

  private

  def render_with_locale
    render("#{request[:action]}_#{I18n.locale}") && return
  end
end
