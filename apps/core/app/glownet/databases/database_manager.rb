class Databases::DatabaseManager
  def initialize(event, type)
    @database = event.method("device_#{type}_db").call
  end

  def generate_url(time)
    s3 = AWS::S3.new(access_key_id: Rails.application.secrets.s3_access_key_id,
                     secret_access_key: Rails.application.secrets.s3_secret_access_key)
    db = s3.buckets[Rails.application.secrets.s3_bucket].objects[@database.path]
    return if db.key.blank?
    db.url_for(:get, expires: Time.zone.now + time.seconds, secure: true).to_s
  end
end
