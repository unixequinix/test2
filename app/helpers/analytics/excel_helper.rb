module Analytics::ExcelHelper
  def handle_response(event, data, response, partial = 'export')
    redirect_to request.referer || admins_events_path, alert: 'Not authorized to perform this action.' unless @current_user.glowball?
    redirect_to request.referer || admins_events_path, notice: 'No data to export yet.' if data.empty?

    response.headers.delete('Content-Length')
    response.headers['Content-Type'] ||= 'application/application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    response.headers['Content-Disposition'] = "attachment; filename=#{event.slug}_#{partial.tr('/', '-')}.xlsx"
    response.headers['X-Accel-Buffering'] = 'no'
    response.headers['Cache-Control'] ||= 'no-cache'

    stream = ExcelIO.new(response.stream)

    klass = data.first.class.to_s.underscore.pluralize
    klass = "credentials" if klass.eql?("arrays")

    begin
      xlsx = Xlsxtream::Workbook.new(stream)
      send("#{klass}_to_xlsx", xlsx, data, event)
      xlsx.close
    ensure
      stream.close
    end
  end

  def credentials_to_xlsx(book, data, event)
    ticket_types = event.ticket_types.map { |ticket_type| [ticket_type.id, ticket_type.catalog_item.credits] }.to_h
    data.each do |arr|
      book.write_worksheet(arr.first.class.to_s.underscore.pluralize) do |sheet|
        sheet << %w[reference redeemed banned operator ticket_type credits customer_name customer_email purchaser_first_name purchaser_last_name purchaser_email].map(&:humanize)

        arr.xlsx_includes.find_in_batches(batch_size: 20_000) do |credentials|
          credentials.each do |credential|
            sheet << [credential.reference, credential.redeemed, credential.banned, credential.operator, credential.ticket_type&.name, ticket_types[credential.ticket_type_id], credential.customer&.name, credential.customer&.email, credential.try(:purchaser_first_name), credential.try(:purchaser_last_name), credential.try(:purchaser_email)]
          end
        end
      end
    end
  end

  def refunds_to_xlsx(book, data, event)
    book.write_worksheet("Online Refunds") do |sheet|
      column_names = %w[customer_name customer_email status created_at gateway ip credit_base credit_fee] + event.refund_fields
      sheet << column_names.map(&:humanize)

      data.xlsx_includes.find_in_batches(batch_size: 20_000) do |refunds|
        refunds.each do |refund|
          sheet << [refund.customer.name, refund.customer.email, refund.status, refund.created_at.strftime("%y-%m-%d %H:%M:%S"), refund.gateway, refund.ip, refund.credit_base, refund.credit_fee] + refund.fields.values
        end
      end
    end
  end

  def orders_to_xlsx(book, data, _event)
    book.write_worksheet("Online Orders") do |sheet|
      column_names = %w[completed_at gateway customer_name customer_email ip status money_fee money_base credits virtual_credits payment_data]
      sheet << column_names.map(&:humanize)

      data.xlsx_includes.find_in_batches(batch_size: 20_000) do |orders|
        orders.each do |order|
          sheet << [order.completed_at, order.gateway, order.customer.name, order.customer.email, order.ip, order.status, order.money_fee, order.money_base, order.credits, order.virtual_credits, order.payment_data]
        end
      end
    end
  end

  def pokes_to_xlsx(book, data, event)
    credits = event.credits.map { |credit| [credit.id, credit.name] }.to_h
    book.write_worksheet("Pokes") do |sheet|
      columns = %w[action description created_at processed_at line_counter gtag_counter device station customer customer_gtag operator operator_gtag ticket ticket_type product order item sale_item_quantity sale_item_unit_price sale_item_total_price standard_unit_price standard_total_price payment_method monetary_quantity monetary_unit_price monetary_total_price credit credit_amount final_balance message priority user_flag_value access_direction].map(&:humanize)
      columns.insert(9, 'Customer email') if event.customer_compliance
      sheet << columns
      data.xlsx_includes.find_in_batches(batch_size: 10_000) do |pokes|
        pokes.each do |poke|
          data = [poke.action, poke.description, poke.date.strftime("%y-%m-%d %H:%M:%S"), poke.created_at.strftime("%y-%m-%d %H:%M:%S"), poke.line_counter, poke.gtag_counter, poke.device.asset_tracker, poke.station.name, poke.customer.name, poke.customer_gtag&.tag_uid, poke.operator.name, poke.operator_gtag&.tag_uid, poke.ticket&.code, poke.ticket_type&.name, poke.product&.name, poke.order_id, poke.catalog_item&.name, poke.sale_item_quantity, poke.sale_item_unit_price, poke.sale_item_total_price, poke.standard_unit_price, poke.standard_total_price, poke.payment_method, poke.monetary_quantity, poke.monetary_unit_price, poke.monetary_total_price, credits[poke.credit_id], poke.credit_amount, poke.final_balance, poke.message, poke.priority, poke.user_flag_value, poke.access_direction]
          data.insert(9, poke.customer.full_email) if event.customer_compliance
          sheet << data
        end
      end
    end
  end

  def event_to_xlsx_file(event)
    Xlsxtream::Workbook.open("#{event.slug}-#{Time.now.to_i}.xlsx") do |book|
      event.pokes.select(:action).distinct.pluck(:action).sort.each do |action|
        pokes_to_xlsx(book, event.pokes.where(action: action), title: action, credits: event.credits)
      end

      orders_to_xlsx(book, event.orders, event)
      refunds_to_xlsx(book, event.refunds, event)
      credentials_to_xlsx(book, [event.gtags, event.tickets], event)
    end
  end

  def tickets_to_xlsx(book, data, _event)
    book.write_worksheet("Tickets") do |sheet|
      column_names = %w[reference customer type redeemed]
      sheet << column_names.map(&:humanize)

      data.xlsx_includes.find_in_batches(batch_size: 20_000) do |tickets|
        tickets.each do |ticket|
          sheet << [ticket.code, ticket.customer ? ticket.customer.name : ticket.purchaser_full_name, ticket.ticket_type.name, ticket.redeemed? ? 'YES' : 'NO']
        end
      end
    end
  end
end
