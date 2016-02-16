class ApplicationMailer < ActionMailer::Base
  include AbstractController::Callbacks

  default from: Rails.application.secrets.from_email,
          content_type: "multipart/mixed",
          parts_order: %w(multipart/alternative text/html text/enriched text/plain application/pdf)
end
