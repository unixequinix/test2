module ApplicationHelper
  # :nocov:
  def link_to_add_fields(name, form, association)
    new_object = form.object.method(association).call.klass.new
    id = new_object.object_id
    fields = form.fields_for(association, new_object, child_index: id) { |builder| render(association.to_s.singularize + "_fields", f: builder) }
    link_to(name, "#", id: "add_fields", class: "add_fields", data: { id: id, fields: fields.delete("\n") })
  end

  def number_to_event_currency(number)
    number_to_currency number.to_f, unit: @current_event.currency_symbol
  end

  def number_to_token(number)
    number_to_currency number, unit: @current_event.credit.symbol
  end

  def number_to_credit(number, credit)
    result = number_with_delimiter(number_with_precision(number, precision: 2))
    result = number.to_f.positive? ? "+#{result}" : result
    number_to_currency result, unit: credit.symbol
  end

  def title
    Rails.env.production? ? "Glownet" : "[#{Rails.env.upcase}] Glownet"
  end

  def can_link?(item)
    ![UserFlag, Credit, VirtualCredit].include?(item&.class)
  end

  def datetime(datetime)
    Time.zone.parse(datetime)
  rescue StandardError
    nil
  end
end
