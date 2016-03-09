class TicketDecoder::SonarDecoder
  def self.perform(encrypted_string)
    key = "\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0E\x0F\x10"
    encrypted_string.slice!(0)
    encrypted_string = [encrypted_string.scan(/.{1,2}/).reverse.join].pack("H*")
    cipher = OpenSSL::Cipher.new("BF-CBC").decrypt
    cipher.key = key
    cipher.iv = key.slice((key.length / 2)..key.length)
    decrypted_string = cipher.update(encrypted_string) << cipher.final
    decrypted_string.force_encoding(Encoding::UTF_8)
    decrypted_string.strip!

    decrypted_string.unpack("H*").first.upcase.scan(/.{1,2}/).reverse.join.to_i(16)
  end
end
