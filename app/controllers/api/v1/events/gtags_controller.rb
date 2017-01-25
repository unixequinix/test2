class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    gtags = gtags_sql || []
    date = @current_event.gtags.maximum(:updated_at)&.httpdate

    render_entity(gtags, date)
  end

  def show
    gtag = @current_event.gtags.find_by(tag_uid: params[:id])

    render(json: :not_found, status: :not_found) && return unless gtag
    render(json: gtag, serializer: Api::V1::GtagSerializer)
  end

  private

  def gtags_sql
    sql = <<-SQL
      SELECT json_strip_nulls(array_to_json(array_agg(row_to_json(g))))
      FROM (
        SELECT
          gtags.tag_uid as reference,
          gtags.banned,
          gtags.updated_at,
          customer_id as customer_id
        FROM gtags
        WHERE
          customer_id is not NULL AND
          gtags.event_id = #{@current_event.id}
          #{"AND gtags.updated_at > '#{@modified}'" if @modified}
      ) g
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end
end
