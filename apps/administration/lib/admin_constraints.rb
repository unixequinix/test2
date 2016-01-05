class AdminConstraints
  def initialize(options)
    @scope = options[:scope]
  end

  def matches?(req)
    req.env["warden"].authenticate!(scope: @scope)
  end
end
