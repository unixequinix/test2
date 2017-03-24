class Api::V1::Events::CustomersController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    customers = customers_sql || []
    all_customers = @current_event.customers
    fresh_when(all_customers.new, etag: all_customers, last_modified: all_customers.maximum(:updated_at), public: true) || render(json: customers)
  end

  def show
    customer = @current_event.customers.find_by(id: params[:id])

    render(status: :not_found, json: :not_found) && return unless customer
    render(json: customer, serializer: Api::V1::CustomerSerializer)
  end

  private

  def customers_sql # rubocop:disable Metrics/MethodLength
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

        LEFT OUTER JOIN (
          SELECT cr.customer_id as customer_id, json_strip_nulls(array_to_json(array_agg(row_to_json(cr)))) as credentials

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
          SELECT o.customer_id as customer_id, json_strip_nulls(array_to_json(array_agg(row_to_json(o)))) as orders

          FROM (
            SELECT
              customer_id,
              counter as id,
              amount,
              catalog_item_id,
              redeemed,
              orders.status

            FROM order_items

            INNER JOIN catalog_items ON catalog_items.id = order_items.catalog_item_id
            INNER JOIN orders ON orders.id = order_items.order_id
            WHERE orders.status IN ('completed', 'cancelled')
          ) o
          GROUP BY o.customer_id
        ) ord
        ON customers.id = ord.customer_id
        WHERE customers.event_id = #{@current_event.id} #{"AND customers.updated_at > '#{@modified}'" if @modified}
      ) cep
    SQL
    ActiveRecord::Base.connection.select_value(sql)
  end
end
