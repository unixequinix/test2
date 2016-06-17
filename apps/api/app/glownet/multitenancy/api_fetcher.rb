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

  def profiles
    @event.profiles.includes(:customer, :credential_assignments, :orders)
  end

  def sql_profiles # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(cep)))
      FROM (
        SELECT
          profiles.id,
          profiles.banned,
          customers.first_name,
          customers.last_name,
          customers.email,
          (
            SELECT array_agg(gateway_type)
            FROM payment_gateway_customers
            WHERE profile_id = profiles.id
              AND agreement_accepted IS TRUE
              AND deleted_at IS NULL
          ) as autotopup_gateways,

        (
          SELECT array_to_json(array_agg(row_to_json(cr)))
          FROM (
            SELECT
              code as reference,
              LOWER(credential_assignments.credentiable_type) as type
            FROM tickets
            INNER JOIN credential_assignments
            ON credential_assignments.profile_id = profiles.id
              AND credential_assignments.credentiable_id = tickets.id
              AND credential_assignments.credentiable_type = 'Ticket'
              AND credential_assignments.aasm_state = 'assigned'
              AND credential_assignments.deleted_at IS NULL
            WHERE tickets.deleted_at IS NULL

            UNION
            SELECT
              tag_uid as reference,
              LOWER(credential_assignments.credentiable_type) as type
            FROM gtags
            INNER JOIN credential_assignments
            ON credential_assignments.profile_id = profiles.id
              AND credential_assignments.credentiable_id = gtags.id
              AND credential_assignments.credentiable_type = 'Gtag'
              AND credential_assignments.aasm_state = 'assigned'
              AND credential_assignments.deleted_at IS NULL
            WHERE gtags.deleted_at IS NULL
          ) cr
        ) as credentials,
        (
          SELECT array_to_json(array_agg(row_to_json(o)))
          from (
            SELECT counter as online_order_counter, customer_orders.amount,
              catalog_items.catalogable_id as catalogable_id,
              LOWER(catalog_items.catalogable_type) as catalogable_type
            FROM online_orders
            INNER JOIN customer_orders
              ON customer_orders.profile_id = profiles.id
              AND customer_orders.deleted_at IS NULL
            INNER JOIN catalog_items
              ON catalog_items.id = customer_orders.catalog_item_id
              AND catalog_items.deleted_at IS NULL
            WHERE online_orders.customer_order_id = customer_orders.id
              AND online_orders.deleted_at IS NULL
              AND online_orders.redeemed IS false
          ) o
        ) as orders
        FROM profiles
        FULL OUTER JOIN customers
          ON customers.id = profiles.customer_id
          AND customers.deleted_at IS NULL
        WHERE profiles.event_id = #{@event.id}
        AND profiles.deleted_at IS NULL
      ) cep
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end

  def device_general_parameters
    @event.event_parameters.where(parameters: { category: "device", group: "general" })
          .includes(:parameter)
  end

  def gtags
    @event.gtags.includes(:credential_assignments, :company_ticket_type, :purchaser)
  end

  def sql_gtags # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT array_to_json(array_agg(row_to_json(g)))
      FROM (
        SELECT gtags.tag_uid as reference,
               gtags.credential_redeemed,
               gtags.banned,
               company_ticket_types.credential_type_id as credential_type_id ,
               purchasers.first_name as purchaser_first_name,
               purchasers.last_name as purchaser_last_name,
               purchasers.email as purchaser_email,
               (
                   SELECT profiles.id as customer_id
                   FROM profiles
                   INNER JOIN credential_assignments ON
                       credential_assignments.profile_id = profiles.id

                   WHERE credential_assignments.credentiable_id = gtags.id
                       AND credential_assignments.credentiable_type = 'Gtag'
                       AND credential_assignments.deleted_at IS NULL
                       AND credential_assignments.aasm_state = 'assigned'
                  LIMIT(1)
               )
        FROM gtags

        LEFT OUTER JOIN purchasers
          ON purchasers.credentiable_id = gtags.id
          AND purchasers.credentiable_type = 'Gtag'
          AND purchasers.deleted_at IS NULL

        LEFT OUTER JOIN company_ticket_types
          ON company_ticket_types.id = gtags.company_ticket_type_id
          AND company_ticket_types.deleted_at IS NULL

        WHERE gtags.event_id = #{@event.id}
        AND gtags.deleted_at IS NULL
      ) g
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end

  def banned_gtags
    @event.gtags.where(banned: true)
  end

  def packs
    Pack.includes(:catalog_item, pack_catalog_items: :catalog_item)
        .where(catalog_items: { event_id: @event.id })
  end

  def parameters
    gtag_type = @event.get_parameter("gtag", "form", "gtag_type")

    @event.event_parameters.joins(:parameter)
          .where("(parameters.category = 'device') OR
              (parameters.category = 'gtag' AND parameters.group = '#{gtag_type}' OR
               parameters.group = 'form' AND parameters.name = 'gtag_type' OR
               parameters.name = 'maximum_gtag_balance')")
  end

  def products
    @event.products
  end

  def stations
    Station.where(event: @event).where.not(category: "customer_portal")
  end

  def sql_tickets # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT json_strip_nulls(array_to_json(array_agg(row_to_json(t))))
      FROM (
        SELECT
          tickets.code as reference,
          tickets.credential_redeemed,
          tickets.banned,
          company_ticket_types.credential_type_id as credential_type_id,
          purchasers.first_name as purchaser_first_name,
          purchasers.last_name as purchaser_last_name,
          purchasers.email as purchaser_email,
          (
              SELECT profiles.id as customer_id
              FROM profiles
              INNER JOIN credential_assignments ON
                  credential_assignments.profile_id = profiles.id

              WHERE credential_assignments.credentiable_id = tickets.id
                  AND credential_assignments.credentiable_type = 'Ticket'
                  AND credential_assignments.deleted_at IS NULL
                  AND credential_assignments.aasm_state = 'assigned'
             LIMIT(1)
          )

        FROM tickets

        LEFT OUTER JOIN purchasers
          ON purchasers.credentiable_id = tickets.id
          AND purchasers.credentiable_type = 'Ticket'
          AND purchasers.deleted_at IS NULL

        INNER JOIN company_ticket_types
          ON company_ticket_types.id = tickets.company_ticket_type_id
          AND company_ticket_types.deleted_at IS NULL
        WHERE tickets.event_id = #{@event.id}
        AND tickets.deleted_at IS NULL
        ORDER BY tickets.created_at ASC #{"LIMIT (10000)" if @event.tickets_api_limit? }
      ) t
    SQL

    ActiveRecord::Base.connection.select_value(sql)
  end

  def banned_tickets
    @event.tickets.where(banned: true)
  end

  def vouchers
    Voucher.includes(:catalog_item, :entitlement).where(catalog_items: { event_id: @event.id })
  end
end
