class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    gtags = gtags_sql || []
    render(json: [].to_json) && return if @current_event.id.eql?(63)
    date = @current_event.gtags.maximum(:updated_at)&.httpdate
    render_entity(gtags, date)
  end

  def show
    gtag = @current_event.gtags.find_by(tag_uid: params[:id])

    render(json: :not_found, status: :not_found) && return unless gtag
    render(json: gtag, serializer: Api::V1::GtagSerializer)
  end

  def banned
    gtags = banned_gtags_sql || []
    date = @current_event.gtags.banned.maximum(:updated_at)&.httpdate

    render_entity(gtags, date)
  end

  private

  def gtags_sql # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT json_strip_nulls(array_to_json(array_agg(row_to_json(g))))
        FROM (
          SELECT
            upper(gtags.tag_uid) as reference,
            gtags.banned,
            gtags.redeemed,
            ticket_types.catalog_item_id as catalog_item_id,
            gtags.ticket_type_id,
            customer_id
          FROM gtags

          LEFT OUTER JOIN ticket_types
            ON ticket_types.id = gtags.ticket_type_id
            AND ticket_types.hidden = false
            AND ticket_types.catalog_item_id IS NOT NULL

        WHERE
          gtags.event_id = #{@current_event.id} AND
          (gtags.customer_id IS NOT NULL OR gtags.banned = TRUE OR catalog_item_id IS NOT NULL)
          #{"AND gtags.updated_at > '#{@modified}'" if @modified}
        ) g
      SQL
    ActiveRecord::Base.connection.select_value(sql)
  end

  def banned_gtags_sql
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
          gtags.event_id = #{@current_event.id}
          AND gtags.banned = TRUE
          #{"AND gtags.updated_at > '#{@modified}'" if @modified}
      ) g
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end
end
