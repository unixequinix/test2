class Multitenancy::ApiFetcher # rubocop:disable Metrics/ClassLength
  def initialize(event)
    @event = event
  end

  def accesses
    Access.joins(:catalog_item, :entitlement).where(catalog_items: { event_id: @event.id })
  end

  def company_ticket_types
    CompanyTicketType.includes(:credential_type, company_event_agreement: :company)
      .where(event: @event)
  end

  def credential_types
    CredentialType.includes(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def credits
    Credit.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def sql_customer_event_profiles # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(cep)))
      FROM (
        SELECT id,
        (
          SELECT first_name  FROM purchasers
          INNER JOIN credential_assignments
            ON credential_assignments.customer_event_profile_id = customer_event_profiles.id
            AND credential_assignments.deleted_at IS NULL
          LIMIT(1)
        ),
        (
          SELECT last_name FROM purchasers
          INNER JOIN credential_assignments
            ON credential_assignments.customer_event_profile_id = customer_event_profiles.id
            AND credential_assignments.deleted_at IS NULL
          LIMIT(1)
        ),
        (
          SELECT email FROM purchasers
          INNER JOIN credential_assignments
            ON credential_assignments.customer_event_profile_id = customer_event_profiles.id
            AND credential_assignments.deleted_at IS NULL
          LIMIT(1)
        ),
        (
          SELECT array_to_json(array_agg(row_to_json(cr)))
          from (
            SELECT credentiable_id as id, credentiable_type as type
            FROM credential_assignments
            WHERE customer_event_profile_id = customer_event_profiles.id
              AND deleted_at IS NULL
          ) cr
        ) as credentials,
        (
          SELECT array_to_json(array_agg(row_to_json(o)))
          from (
            SELECT counter as online_order_counter, customer_orders.amount,
              customer_orders.catalog_item_id as catalogable_id,
              catalog_items.catalogable_type as catalogable_type
            FROM online_orders
            INNER JOIN customer_orders
              ON customer_orders.customer_event_profile_id = customer_event_profiles.id
              AND customer_orders.deleted_at IS NULL
            INNER JOIN catalog_items
              ON catalog_items.id = customer_orders.catalog_item_id
              AND catalog_items.deleted_at IS NULL
            WHERE online_orders.customer_order_id = customer_orders.id
              AND online_orders.deleted_at IS NULL
              AND online_orders.redeemed IS false
          ) o
        ) as orders
        FROM customer_event_profiles
        WHERE customer_event_profiles.event_id = #{@event.id}
      ) cep
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end

  def event_parameters
    EventParameter.where(event: @event)
  end

  def device_general_parameters
    EventParameter.where(event: @event, parameters: { category: "device", group: "general" })
      .includes(:parameter)
  end

  def gtags
    Gtag.includes(:credential_assignments, :company_ticket_type, :purchaser).where(event: @event)
  end

  def sql_gtags # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(g)))
      FROM (
        SELECT gtags.id, gtags.tag_uid, gtags.tag_serial_number, gtags.credential_redeemed,
               credential_assignments.customer_event_profile_id as customer_id,
               company_ticket_types.credential_type_id as credential_type_id ,
               purchasers.first_name as purchaser_first_name,
               purchasers.last_name as purchaser_last_name,
               purchasers.email as purchaser_email
        FROM gtags
        FULL OUTER JOIN purchasers
          ON purchasers.credentiable_id = gtags.id
          AND purchasers.credentiable_type = 'Gtag'
          AND purchasers.deleted_at IS NULL
        FULL OUTER JOIN credential_assignments
          ON credential_assignments.credentiable_id = gtags.id
          AND credential_assignments.credentiable_type = 'Gtag'
          AND credential_assignments.deleted_at IS NULL
        INNER JOIN company_ticket_types
          ON company_ticket_types.id = gtags.company_ticket_type_id
          AND company_ticket_types.deleted_at IS NULL
        WHERE gtags.event_id = #{@event.id}
      ) g
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end

  def banned_gtags
    Gtag.banned.where(event: @event)
  end

  def packs
    Pack.includes(:catalog_item, pack_catalog_items: :catalog_item)
      .where(catalog_items: { event_id: @event.id })
  end

  def stations
    StationGroup.includes(stations: :station_type).where(stations: { event_id: @event.id })
  end

  def sale_stations
    Station.joins(:station_type)
      .where(event: @event, station_types: { name: Station::SALE_STATIONS })
  end

  def station_catalog_items
    StationCatalogItem.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def sql_tickets # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(t)))
      FROM (
        SELECT tickets.id, tickets.code as reference, tickets.credential_redeemed,
               credential_assignments.customer_event_profile_id as customer_id,
               company_ticket_types.credential_type_id as credential_type_id ,
               purchasers.first_name as purchaser_first_name,
               purchasers.last_name as purchaser_last_name,
               purchasers.email as purchaser_email
        FROM tickets
        FULL OUTER JOIN purchasers
          ON purchasers.credentiable_id = tickets.id
          AND purchasers.credentiable_type = 'Ticket'
          AND purchasers.deleted_at IS NULL
        FULL OUTER JOIN credential_assignments
          ON credential_assignments.credentiable_id = tickets.id
          AND credential_assignments.credentiable_type = 'Ticket'
          AND credential_assignments.deleted_at IS NULL
        INNER JOIN company_ticket_types
          ON company_ticket_types.id = tickets.company_ticket_type_id
          AND company_ticket_types.deleted_at IS NULL
        WHERE tickets.event_id = #{@event.id}
      ) t
    SQL

    ActiveRecord::Base.connection.select_value(sql)
  end

  def banned_tickets
    @event.tickets.banned
  end

  def vouchers
    Voucher.includes(:catalog_item, :entitlement).where(catalog_items: { event_id: @event.id })
  end
end
