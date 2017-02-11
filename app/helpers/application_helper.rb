module ApplicationHelper
  # :nocov:
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) { |builder| render(association.to_s.singularize + "_fields", f: builder) }
    link_to(name, "#", class: "add_fields", data: { id: id, fields: fields.delete("\n") })
  end
  # :nocov:

  def number_to_token(number)
    number_to_currency number, unit: @current_event.credit.name + " "
  end

  def title
    Rails.env.production? ? "Glownet" : "[#{Rails.env.upcase}] Glownet"
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def format_abstract_value(value)
    case value
      when true then fa_icon('check')
      when "true" then fa_icon('check')
      when false then fa_icon('times')
      when "false" then fa_icon('times')
      when nil then content_tag(:em, "Empty")
      when "" then content_tag(:em, "Empty")
      else value
    end
  end
end
