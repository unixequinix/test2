class TicketDecoder::SonarDecoder
  def self.perform(encrypted_string)
    # Remove first letter which inicates tpe of ticket. Eg: 'T'
    encrypted_string.slice!(0)

    key = "\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0E\x0F\x10"
    encrypted_string = [reverse_hex(encrypted_string)].pack("H*")
    cipher = OpenSSL::Cipher.new("BF-CBC").decrypt
    cipher.key = key
    cipher.iv = key.slice((key.length / 2)..key.length)
    decrypted_string = cipher.update(encrypted_string) << cipher.final

    reverse_hex(decrypted_string.unpack("H*").first.upcase).to_i(16)
  end

  def self.reverse_hex(data)
    data.scan(/.{1,2}/).reverse.join
  end
end
