class Authentication::Encryptor
  def self.digest(password)
    password = "#{password}#{Rails.application.secrets.devise_pepper}"
    ::BCrypt::Password.create(password, cost: 10).to_s
  end

  def self.compare(encrypted_password, password)
    return false if encrypted_password.blank?
    bcrypt   = ::BCrypt::Password.new(encrypted_password)
    password = "#{password}#{Rails.application.secrets.devise_pepper}"
    password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
    password == encrypted_password
  end

  # constant-time comparison algorithm to prevent timing attacks
  def secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end
