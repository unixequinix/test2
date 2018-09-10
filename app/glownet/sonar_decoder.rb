class SonarDecoder
  PREFIX = "2018".freeze

  def self.perform(ticket_code)
    return nil if ticket_code.blank?
    ticket_number = decode(ticket_code)
    return nil unless verify_prefix(ticket_number)
    ticket_number.to_s[-3..-1]
  end

  def self.decode(ticket_code)
    ticket_code = [reverse_hex(ticket_code.to_s[1..-1])].pack("H*")
    cipher = OpenSSL::Cipher.new("bf").decrypt
    cipher.key = key
    cipher.iv = key.slice((key.length / 2)..key.length)

    begin
      decrypted_string = cipher.update(ticket_code) << cipher.final
    rescue OpenSSL::Cipher::CipherError
      return nil
    end

    reverse_hex(decrypted_string.unpack1("H*")).to_i(16).to_s
  end

  def self.key
    [Rails.application.secrets.ticket_config_1.delete(":")].pack("H*")
  end

  def self.verify_prefix(code)
    code.to_s.starts_with? PREFIX
  end

  def self.valid_code?(code)
    return false if code.blank?
    verify_prefix(decode(code))
  end

  def self.reverse_hex(data)
    data.to_s.scan(/.{1,2}/).reverse.join
  end
end
