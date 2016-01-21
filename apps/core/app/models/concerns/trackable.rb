module Trackable
  extend ActiveSupport::Concern

  def update_tracked_fields!(request)
    self.last_sign_in_at = current_sign_in_at || Time.now.utc
    self.current_sign_in_at = Time.now.utc

    self.last_sign_in_ip = current_sign_in_ip || request.env["REMOTE_ADDR"]
    self.current_sign_in_ip = request.env["REMOTE_ADDR"]

    self.sign_in_count ||= 0
    self.sign_in_count += 1
    save!
  end
end
