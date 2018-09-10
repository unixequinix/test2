class AwsManager
  def self.generate_url(path, time = 5)
    secrets = Rails.application.secrets
    credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
    s3 = Aws::S3::Resource.new(region: 'eu-west-1', credentials: credentials)
    db = s3.bucket(Rails.application.secrets.s3_bucket).object(path)

    return if db.blank? || db.key.blank?
    db.presigned_url(:get, expires_in: time.minutes.to_i, secure: true).to_s # expires in 1 week
  end
end
