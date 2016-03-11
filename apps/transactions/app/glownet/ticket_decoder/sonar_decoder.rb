class TicketDecoder::SonarDecoder
  def self.perform(encrypted_string)
    encrypted_string.slice!(0)
    encrypted_string = [reverse_hex(encrypted_string)].pack("H*")
    cipher = OpenSSL::Cipher.new("BF-CBC").decrypt
    key = Rails.application.secrets.ticket_config_1
    cipher.key = key
    cipher.iv = key.slice((key.length / 2)..key.length)
    decrypted_string = cipher.update(encrypted_string) << cipher.final

    code = reverse_hex(decrypted_string.unpack("H*").first).to_i(16)
    verify_code(code)
  end

  def self.verify_code(code)
    code
  end

  def self.reverse_hex(data)
    data.scan(/.{1,2}/).reverse.join
  end
end
