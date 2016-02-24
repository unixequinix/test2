class TicketDecoder::SonarDecoder
  def self.perform(encrypted_string, salt = nil)
    encrypted_string.slice!(0)

    cipher = OpenSSL::Cipher.new("BF-CBC").decrypt
    cipher.padding = 0
    cipher.iv = "09:0a:0b:0c:0d:0e:0f:10"
    cipher.key = "01:02:03:04:05:06:07:08:09:0a:0b:0c:0d:0e:0f:10"

    binary_data = [encrypted_string].pack("H*")
    decrypted_string = cipher.update(binary_data) << cipher.final
    decrypted_string.force_encoding(Encoding::UTF_8)

    decrypted_string.strip!
    decrypted_string.gsub!(/#{Regexp.quote(salt)}$/, "") unless salt.nil?

    decrypted_string
  end
end
