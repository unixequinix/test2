module Api::V2
  module Events
    module Analytics
      class BaseAnalyticsController < BaseController
        before_action :parse_action_method

        def parse_action_method
          authorize @current_user, policy_class: ApiAnalyticsPolicy
          concern = Object.const_get(params[:controller].split('/').last.classify.pluralize)
          action_method = params[:action_method].to_sym
          if @current_event.present? && concern.present? && concern.instance_methods.include?(action_method)
            available_filters = @current_event.method(action_method).parameters.map { |p| { p[1] => params[p[1].to_s] } }
            @results = @current_event.try(action_method, available_filters.reduce({}, :merge).compact)
          else
            render(status: :bad_request, json: { error: :bad_request })
          end
        end
      end
    end
  end
end
