module ApplicationHelper
  # :nocov:
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) { |builder| render(association.to_s.singularize + "_fields", f: builder) }
    link_to(name, "#", class: "add_fields", data: { id: id, fields: fields.delete("\n") })
  end

  def number_to_event_currency(number)
    number_to_currency number.to_f, unit: @current_event.currency_symbol
  end

  def number_to_token(number)
    number_to_currency number, unit: @current_event.credit.symbol
  end

  def title
    Rails.env.production? ? "Glownet" : "[#{Rails.env.upcase}] Glownet"
  end
end
