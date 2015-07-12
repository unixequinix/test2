class ApplicationMailer < ActionMailer::Base
  include AbstractController::Callbacks
  before_filter :set_i18n_globals

  default from: Rails.application.secrets.from_email,
          content_type: 'multipart/mixed',
          parts_order: [ "multipart/alternative", "text/html", "text/enriched", "text/plain", "application/pdf" ]

  def set_i18n_globals
    I18n.config.globals[:gtag] = 'Paycard'
  end
end