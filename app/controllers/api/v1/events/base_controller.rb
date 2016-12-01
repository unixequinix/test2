# rubocop:disable Metrics/ClassLength
class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_action :api_enabled
  serialization_scope :current_event

  def render_entities(entity)
    modified = request.headers["If-Modified-Since"]&.to_datetime

    obj = method(entity.pluralize).call
    table = %w( access credit pack user_flag ).include?(entity) ? "catalog_items" : entity.pluralize

    if modified
      obj = obj.where("#{table}.updated_at > ?", modified)
      status = obj.present? ? 200 : 304
    end

    date = obj.maximum(:updated_at)&.httpdate
    response.headers["Last-Modified"] = date if date

    status ||= 200
    render(status: status, json: obj, each_serializer: "Api::V1::#{entity.camelcase}Serializer".constantize)
  end

  def api_enabled
    return unless current_event.finished?
    render(status: :unauthorized, json: :unauthorized)
  end

  private

  def user_flags
    current_event.user_flags
  end

  def accesses
    current_event.accesses.includes(:entitlement)
  end

  def ticket_types
    current_event.ticket_types
  end

  def credits
    Credit.where(id: current_event.credit.id)
  end

  def sql_customers(date) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(json_strip_nulls(row_to_json(cep))))
      FROM (
        SELECT
          customers.id,
          customers.banned,
          customers.updated_at,
          customers.first_name,
          customers.last_name,
          customers.email,
          cred.credentials,
          ord.orders

        FROM customers

        LEFT OUTER JOIN (
          SELECT cr.customer_id as customer_id, array_to_json(array_agg(row_to_json(cr))) as credentials
          FROM (
            SELECT customer_id, code as reference, 'ticket' as type
            FROM tickets
            UNION
            SELECT customer_id, tag_uid as reference, 'gtag' as type
            FROM gtags
            WHERE gtags.active = true
          ) cr
          GROUP BY cr.customer_id
        ) cred
        ON customers.id = cred.customer_id

        LEFT OUTER JOIN (
          SELECT o.customer_id as customer_id, array_to_json(array_agg(row_to_json(o))) as orders
          FROM (
            SELECT
              customer_id,
              counter as id,
              amount,
              catalog_item_id,
              redeemed
            FROM order_items
            INNER JOIN catalog_items
              ON catalog_items.id = order_items.catalog_item_id
            INNER JOIN orders
              ON orders.id = order_items.order_id
          ) o
          GROUP BY o.customer_id
        ) ord
        ON customers.id = ord.customer_id
        WHERE customers.event_id = #{current_event.id} #{"AND customers.updated_at > '#{date}'" if date}
      ) cep
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    sql
  end

  def sql_gtags(date) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(json_strip_nulls(row_to_json(g))))
      FROM (
        SELECT
          gtags.tag_uid as reference,
          gtags.banned,
          gtags.updated_at,
          customer_id as customer_id

        FROM gtags
        WHERE gtags.event_id = #{current_event.id} #{"AND gtags.updated_at > '#{date}'" if date}
      ) g
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    sql
  end

  def banned_gtags
    current_event.gtags.where(banned: true)
  end

  def packs
    current_event.packs.includes(pack_catalog_items: :catalog_item)
  end

  def products
    current_event.products
  end

  def sql_tickets(date) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(json_strip_nulls(row_to_json(t))))
      FROM (
        SELECT
          tickets.code as reference,
          tickets.redeemed,
          tickets.purchaser_first_name,
          tickets.purchaser_last_name,
          tickets.purchaser_email,
          tickets.banned,
          tickets.updated_at,
          ticket_types.catalog_item_id,
          customer_id

        FROM tickets

        INNER JOIN ticket_types
          ON ticket_types.id = tickets.ticket_type_id
          AND ticket_types.hidden = false

        WHERE tickets.event_id = #{current_event.id} #{"AND tickets.updated_at > '#{date}'" if date}
      ) t
    SQL

    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    sql
  end

  def banned_tickets
    tickets.where(banned: true)
  end
end
