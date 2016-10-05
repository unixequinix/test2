# rubocop:disable Metrics/ClassLength
class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_action :api_enabled
  serialization_scope :current_event

  def render_entities(entity)
    plural = entity.pluralize
    modified = request.headers["If-Modified-Since"]&.to_datetime

    obj = method(plural).call
    plural = plural.gsub("banned_", "") if plural.starts_with?("banned")
    if modified
      obj = obj.where("#{plural}.updated_at > ?", modified)
      status = obj.present? ? 200 : 304
    end

    date = obj.maximum(:updated_at)&.httpdate
    response.headers["Last-Modified"] = date if date

    status ||= 200
    render(status: status, json: obj, each_serializer: "Api::V1::#{entity.camelcase}Serializer".constantize)
  end

  def api_enabled
    return if current_event.devices_api?
    render(status: :unauthorized, json: :unauthorized)
  end

  private

  def accesses
    current_event.accesses.includes(:entitlement, :catalog_item)
  end

  def company_ticket_types
    current_event.company_ticket_types
  end

  def credential_types
    current_event.credential_types
  end

  def credits
    current_event.credits
  end

  def sql_profiles(date) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(cep)))
      FROM (
        SELECT
          profiles.id,
          profiles.banned,
          profiles.updated_at,
          customers.first_name,
          customers.last_name,
          customers.email,
          cred.credentials,
          ord.orders,
          gateways.gateway_types as autotopup_gateways

        FROM profiles

        LEFT OUTER JOIN (
          SELECT profile_id, array_agg(gateway_type) as gateway_types
          FROM payment_gateway_customers
          WHERE agreement_accepted IS TRUE
            AND deleted_at IS NULL
          GROUP BY profile_id
        ) gateways
          ON gateways.profile_id = profiles.id

        LEFT OUTER JOIN (
          SELECT cr.profile_id as profile_id, array_to_json(array_agg(row_to_json(cr))) as credentials
          FROM (
            SELECT
              credential_assignments.profile_id as profile_id,
              code as reference,
              LOWER(credential_assignments.credentiable_type) as type
            FROM tickets
            INNER JOIN credential_assignments
            ON credential_assignments.credentiable_id = tickets.id
              AND credential_assignments.credentiable_type = 'Ticket'
              AND credential_assignments.aasm_state = 'assigned'
              AND credential_assignments.deleted_at IS NULL
            WHERE tickets.deleted_at IS NULL
            UNION
            SELECT
              credential_assignments.profile_id as profile_id,
              tag_uid as reference,
              LOWER(credential_assignments.credentiable_type) as type
            FROM gtags
            INNER JOIN credential_assignments
            ON credential_assignments.credentiable_id = gtags.id
              AND credential_assignments.credentiable_type = 'Gtag'
              AND credential_assignments.aasm_state = 'assigned'
              AND credential_assignments.deleted_at IS NULL
            WHERE gtags.deleted_at IS NULL
          ) cr
          GROUP BY cr.profile_id
        ) cred
        ON profiles.id = cred.profile_id

        LEFT OUTER JOIN (
          SELECT o.profile_id as profile_id, array_to_json(array_agg(row_to_json(o))) as orders
          from (
            SELECT
              customer_orders.profile_id as profile_id,
              counter as online_order_counter,
              customer_orders.amount,
              catalog_items.catalogable_id as catalogable_id,
              LOWER(catalog_items.catalogable_type) as catalogable_type
            FROM online_orders
            INNER JOIN customer_orders
              ON online_orders.customer_order_id = customer_orders.id
              AND customer_orders.deleted_at IS NULL
            INNER JOIN catalog_items
              ON catalog_items.id = customer_orders.catalog_item_id
              AND catalog_items.deleted_at IS NULL
            WHERE online_orders.deleted_at IS NULL
              AND online_orders.redeemed IS false
          ) o
          GROUP BY o.profile_id
        ) ord
        ON profiles.id = ord.profile_id

        LEFT OUTER JOIN customers
          ON customers.id = profiles.customer_id
          AND customers.deleted_at IS NULL

        WHERE profiles.event_id = #{current_event.id}
        AND profiles.deleted_at IS NULL #{"AND profiles.updated_at > '#{date}'" if date}
      ) cep
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    sql
  end

  def device_general_parameters
    current_event.device_general_parameters
  end

  def sql_gtags(date) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(g)))
      FROM (
        SELECT
          gtags.tag_uid as reference,
          gtags.banned,
          gtags.updated_at,
          cred.profile_id as customer_id

        FROM gtags

        LEFT OUTER JOIN  credential_assignments cred
          ON cred.credentiable_id = gtags.id
          AND cred.credentiable_type = 'Gtag'
          AND cred.deleted_at IS NULL
          AND cred.aasm_state = 'assigned'

        WHERE gtags.event_id = #{current_event.id}
        AND gtags.deleted_at IS NULL #{"AND gtags.updated_at > '#{date}'" if date}
      ) g
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    sql
  end

  def banned_gtags
    gtags.where(banned: true)
  end

  def packs
    current_event.packs.includes(:catalog_item, pack_catalog_items: :catalog_item)
  end

  def event_parameters
    gtag_type = current_event.get_parameter("gtag", "form", "gtag_type")

    current_event.event_parameters.joins(:parameter)
                 .where("(parameters.category = 'device') OR
                         (parameters.category = 'gtag' AND parameters.group = '#{gtag_type}' OR
                          parameters.group = 'form' AND parameters.name = 'gtag_type' OR
                          parameters.name = 'maximum_gtag_balance' OR
                          parameters.name = 'gtag_deposit')")
  end

  def products
    current_event.products
  end

  def sql_tickets(date) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(t)))
      FROM (
        SELECT
          tickets.code as reference,
          tickets.credential_redeemed,
          tickets.banned,
          tickets.updated_at,
          company_ticket_types.credential_type_id as credential_type_id,
          cred.profile_id as customer_id

        FROM tickets

        LEFT OUTER JOIN  credential_assignments cred
          ON cred.credentiable_id = tickets.id
          AND cred.credentiable_type = 'Ticket'
          AND cred.deleted_at IS NULL
          AND cred.aasm_state = 'assigned'

        INNER JOIN company_ticket_types
          ON company_ticket_types.id = tickets.company_ticket_type_id
          AND company_ticket_types.deleted_at IS NULL
          AND company_ticket_types.hidden = false

        WHERE tickets.event_id = #{current_event.id}
        AND tickets.deleted_at IS NULL #{"AND tickets.updated_at > '#{date}'" if date}
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
