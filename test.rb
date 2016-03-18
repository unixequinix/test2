require 'net/http'
require 'net/https'
require 'json'
require 'uri'

uri = URI('https://sandbox.glownet.com/companies/api/v1/tickets/blacklist/')
event_token = '5F57C1F9E665'
company_token = '5faeccd97ff3f6cc931a595dc0dbf3b9'

uri = URI.parse('https://sandbox.glownet.com/companies/api/v1/tickets/blacklist/')
https = Net::HTTP.new(uri.host,uri.port)
https.use_ssl = true
req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
req.basic_auth event_token, company_token
req.body = JSON.generate({
 tickets_blacklist: {
   ticket_reference: "TC8B106BA990BDC56"
 }
})
res = https.request(req)
puts "Response #{res.code} #{res.message}: #{res.body}"-
