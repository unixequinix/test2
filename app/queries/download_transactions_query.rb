class DownloadTransactionsQuery
  def initialize(event)
    @event = event
  end

  def all
    ActiveRecord::Base.connection.execute(query).values
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["Event Name", "Transaction Origin", "Transaction Category", "Event Day", "Date Time", "Station Name", "Station Location", "Station Category", "Station Address", "Station Official Name", "Device UID", "Customer gTag ID", "Operator gTag ID", "Product Price", "Product Name", "Product has Acohol?", "Product description", "Product VAT", "Transaction Type", "Total Transaction Amount", "Total Transaction Amount Refundable", "Final Balance", "Final Balance Refundable", "Quantity", "Unit Price", "Other Amount Sale", "Products Amount Sale", "Amount"]
      all.each { |row| csv << row }
    end
  end

  private

  def query
    <<-SQL
      SELECT
        ev.name AS "Event Name",
        tr.transaction_origin      AS "Transaction Origin",
        tr.type                    AS "Transaction Category",

        to_char(date(to_timestamp(left(tr.device_created_at, 19), 'YYYY-MM-DD HH24:MI:SS') - INTERVAL '8h'), 'DD/MM/YYYY')
        AS "Event Day",
        to_char(to_timestamp(left(tr.device_created_at, 19), 'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS')
        AS "Date Time",

        st.name AS "Station Name",
        st.location AS "Station Location",
        st.category AS "Station Category",
        st.address AS "Station Address",
        st.official_name AS "Station Official Name",
        tr.device_id			         AS "Device ID",
        tr.customer_tag_uid        AS "Customer gTag ID",
        tr.operator_tag_uid        AS "Operator gTag ID",

        sale_items.price AS "Product Price",
        sale_items.name AS "Product Name",
        sale_items.is_alcohol AS "Product has Acohol?",
        sale_items.description "Product description",
        sale_items.vat "Product VAT",
        CASE tr.action
        WHEN 'sale_refund' THEN 'sale'
        ELSE tr.action
        END                      AS "Transaction Type",

        sum(tr.credits)                            AS "Total Transaction Amount",
        sum(tr.refundable_credits)               AS "Total Transaction Amount Refundable",
        sum(tr.final_balance)                      AS "Final Balance",
        sum(tr.final_refundable_balance)          AS "Final Balance Refundable",
        sum(COALESCE(quantity, 1)) AS "Quantity",
        sum(COALESCE(standard_unit_price, credits)) AS "Unit Price",
        sum( tr.other_amount_credits) AS "Other Amount Sale",
        sum(tr.credits - tr.other_amount_credits) AS "Products Amount Sale",
        sum(COALESCE(amount, credits)) AS "Amount"

        FROM
          transactions AS tr
          JOIN events ev ON tr.event_id = ev.id
            AND tr.type = 'CreditTransaction'
            AND tr.status_code IN (0)
            AND tr.event_id = #{@event.id}

          JOIN stations st ON tr.station_id = st.id

          LEFT JOIN (
            SELECT
              sale_items.id,
              credit_transaction_id,
              quantity,
              standard_unit_price as unit_price,
              -1 * quantity * unit_price as amount,
              price,
              name,
              is_alcohol ,
              description ,
              vat
          FROM sale_items
              JOIN products ON sale_items.product_id = products.id
          UNION ALL
          SELECT
            0 as id,
            tr.id as credit_transaction_id,
            1 as quantity,
            0 as unit_price,
            tr.other_amount_credits as amount,
            other_amount_credits AS price,
            'Other Amount' AS name,
            FALSE AS is_alcohol ,
            'Other Amount' AS description ,
            0 as vat
          FROM transactions tr
          WHERE
          tr.other_amount_credits IS NOT NULL
          AND tr.other_amount_credits !=0
          AND tr.action in ('sale', 'sale_refund')
          AND tr.status_code IN (0)
          AND tr.event_id = #{@event.id}
            ) sale_items ON tr.id = sale_items.credit_transaction_id


        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19

        ;
    SQL
  end
end
