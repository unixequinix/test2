module Api
  module V1
    module Events
      class UserFlagsController < Api::V1::EventsController
        before_action :set_modified

        def index
          user_flags = @current_event.user_flags
          user_flags = user_flags.where("catalog_items.updated_at > ?", @modified) if @modified
          date = user_flags.maximum(:updated_at)&.httpdate
          user_flags = user_flags.map { |a| UserFlagSerializer.new(a) }.as_json if user_flags.present?

          render_entity(user_flags, date)
        end
      end
    end
  end
end
