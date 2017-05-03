module ApplicationHelper
  # :nocov:
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) { |builder| render(association.to_s.singularize + "_fields", f: builder) }
    link_to(name, "#", class: "add_fields", data: { id: id, fields: fields.delete("\n") })
  end

  def number_to_event_currency(number)
    number_to_currency number, unit: @current_event.currency, format: "%u %n"
  end

  def number_to_token(number)
    unit = number > 1 ? @current_event.credit.name.pluralize : @current_event.credit.name
    number_to_currency number, unit: unit, format: "%n %u"
  end

  def title
    Rails.env.production? ? "Glownet" : "[#{Rails.env.upcase}] Glownet"
  end
end
