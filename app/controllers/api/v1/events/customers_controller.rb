module Api
  module V1
    module Events
      class CustomersController < Api::V1::Events::BaseController
        before_action :set_modified

        def index
          last_modified = @current_event.customers.maximum(:updated_at)
          fresh_when(@current_event.customers.new, etag: @current_event.customers, last_modified: last_modified, public: true) && return
          render(json: customers_sql)
        end

        def show
          customer = @current_event.customers.find_by(id: params[:id])

          render(status: :not_found, json: :not_found) && return unless customer
          render(json: customer, serializer: CustomerSerializer)
        end

        private

        # * have online orders with status 'completed' or 'cancelled' or
        # * have tickets at all or (right now we dont check this!)
        # * have tags with ticket_type which has a catalog_item
        def customers_sql # rubocop:disable Metrics/MethodLength
          cids = @modified.present? ? @current_event.customers.where("updated_at > ?", @modified).pluck(:id) : @current_event.customers.pluck(:id)
          order_cids = @current_event.orders.where(status: %w[completed cancelled], customer_id: cids).pluck(:customer_id)
          gtag_cids = @current_event.gtags.where(active: true, customer_id: cids).where.not(ticket_type: nil).pluck(:customer_id)
          ticket_cids = @current_event.tickets.where(customer_id: cids).where.not(ticket_type: nil).pluck(:customer_id)

          ids = (order_cids + gtag_cids + ticket_cids).uniq
          return [].to_json unless ids.any?

          sql = <<-SQL
          SELECT json_strip_nulls(array_to_json(array_agg(row_to_json(cep))))
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

              LEFT JOIN (
                SELECT
                  cr.customer_id AS customer_id,
                  json_strip_nulls(array_to_json(array_agg(row_to_json(cr)))) AS credentials
                FROM (
                  SELECT
                    customer_id,
                    code     AS reference,
                    redeemed,
                    'ticket' AS type
                  FROM tickets
                  WHERE tickets.customer_id IN (#{ids.join(', ')})

                  UNION ALL

                  SELECT
                    customer_id,
                    tag_uid AS reference,
                    redeemed,
                    'gtag'  AS type
                  FROM gtags
                  WHERE gtags.customer_id IN (#{ids.join(', ')})
                ) cr GROUP BY cr.customer_id
              ) cred ON customers.id = cred.customer_id

        LEFT JOIN (
          SELECT
            o.customer_id                                              AS customer_id,
            json_strip_nulls(array_to_json(array_agg(row_to_json(o)))) AS orders
          FROM (
            SELECT
              order_items.id,
              counter,
              customer_id,
              amount,
              catalog_item_id,
              catalog_items.type as catalog_item_type,
              redeemed,
              'completed' as status
            FROM order_items
              JOIN catalog_items ON catalog_items.id = order_items.catalog_item_id
              JOIN orders ON orders.id = order_items.order_id
                AND orders.customer_id IN (#{ids.join(', ')})
                AND orders.status = 3
          ) o GROUP BY o.customer_id
        ) ord ON customers.id = ord.customer_id

            WHERE customers.id IN (#{ids.join(', ')})
          ) cep
          SQL
          ActiveRecord::Base.connection.select_value(sql)
        end
      end
    end
  end
end
