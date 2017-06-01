# ActiveSupport::JSON::Encoding.use_standard_json_time_format = false
#
# Date::DATE_FORMATS[:default] = "%FT%T.%L%z"
# Time::DATE_FORMATS[:default] = "%FT%T.%L%z"
# DateTime::DATE_FORMATS[:default] = "%FT%T.%L%z"
#
# class ActiveSupport::TimeWithZone
#   def as_json(options = {})
#     strftime("%FT%T.%L%z")
#   end
# end

Time::DATE_FORMATS[:transactions] = "%Y-%m-%dT%T"