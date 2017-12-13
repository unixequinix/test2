class Rack::Attack
  def self.reset_throttle(name, discriminator)
    if (throttle = (@throttles.detect { |t| t.first == name })[1])
      throttle.reset(discriminator)
    end
  end

  # `Rack::Attack` is configured to use the `Rails.cache` value by default,
  # but you can override that by setting the `Rack::Attack.cache.store` value
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Allow all local traffic
  safelist('allow-localhost') do |req|
   '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Allow an IP address to make 50 requests every 5 seconds
  

  # Throttle login attempts by email address
  throttle("/users/sign_in", limit: 5, period: 60.minutes, type: :recaptcha) do |req|
    req.params['user']['login'].presence if req.path == '/users/sign_in' && req.post?
  end

  # Throttle login attempts by email address
  throttle("/:event/login", limit: 10, period: 60.minutes, type: :recaptcha) do |req|
    req.params['customer']['email'].presence if req.path.include?('/login') && req.post?
  end

  # Send the following response to throttled clients
  self.throttled_response = ->(env) {
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s},
      [{error: "Throttle limit reached. Retry later."}.to_json]
    ]
  }
end

class Rack::Attack::Throttle
  def reset(discriminator)
    current_period = period.respond_to?(:call) ? period.call(req) : period
    cache.reset_count "#{name}:#{discriminator}", current_period
  end
end

class Rack::Attack::Cache
  def reset_count(unprefixed_key, period)
    epoch_time = Time.now.to_i
    # Add 1 to expires_in to avoid timing error: http://git.io/i1PHXA
    expires_in = period - (epoch_time % period) + 1
    key = "#{prefix}:#{(epoch_time/period).to_i}:#{unprefixed_key}"
    store.write(key, 0, :expires_in => expires_in)
  end
end
