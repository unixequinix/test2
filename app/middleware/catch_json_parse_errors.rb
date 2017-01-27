# in app/middleware/catch_json_parse_errors.rb
class CatchJsonParseErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionDispatch::ParamsParser::ParseError => error
    raise error unless env["HTTP_ACCEPT"] =~ %r{application\/json} || env["CONTENT_TYPE"] =~ %r{application\/json}
    error_output = "There was a problem in the JSON you submitted: #{error}"
    return [400, { "Content-Type" => "application/json" }, [{ status: :bad_request, error: error_output }.to_json]]
  end
end
