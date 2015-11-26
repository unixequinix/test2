class TipaltiCheckoutService

  def initialize
    # @payer = "Demo1"
    # @idap = "payeeToOpenHere"
    # @secret_key = "FEVUEmSW41JnFY5GukJTM/l24usNpSQiuus3ySeoDGntOOGkqlBrp4Eu8tMrv506"
    @payer = "Glownet"
    @idap = "payeeToOpenHere"
    @secret_key = "n6RwV8g/lM7IP51GWqOmcsTmJ9YSu4YpteoYHuXPmymjB1oaIimAC6lm3EUWxBoT"
  end

  def url
    #base_url = "https://ui.tipalti.com" #production
    base_url = "https://ui.sandbox.tipalti.com" #sandbox
    base_url + "/Payees/PayeeDashboard.aspx?" + create_value + "&hashkey=" + crypt(create_value)
  end


  def create_value
    valid_characters = /[^0-9A-Za-zñÑ\-,'"ªº]/

    value = "idap=#{@idap}"
    value += "&last=Smith"
    value += "&first=John"
    value += "&ts=#{Time.now.to_i}"
    value += "&payer=#{@payer}"
  end

  def crypt(value)
    sha256 = OpenSSL::Digest.new('sha256')
    result = OpenSSL::HMAC.digest(sha256, @secret_key, value)
    result.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join
  end
end