module AsyncHelper
  def eventually(options = {}) # rubocop:disable all
    timeout = options[:timeout] || 2
    interval = options[:interval] || 0.1
    time_limit = Time.zone.now + timeout

    loop do
      begin
        yield
      rescue RSpec::Expectations::ExpectationNotMetError, StandardError => error

      end

      return if error.nil?
      raise error if Time.zone.now >= time_limit
      sleep interval
    end
  end
end
