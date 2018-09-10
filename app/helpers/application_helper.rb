module ApplicationHelper
  # :nocov:
  def admin_or_promoter_or(*roles)
    registration = @current_user.registration_for(@current_event)
    @current_user.admin? || registration&.promoter? || roles.any? { |role| registration.method("#{role}?".to_sym).call }
  end

  def admin_or_promoter
    @current_user.admin? || @current_user.registration_for(@current_event)&.promoter?
  end

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

  def number_to_reports(number)
    number_with_delimiter(number_with_precision(number, precision: 2))
  end

  def number_to_reports_currency(number)
    number_to_currency number, unit: @current_event.currency_symbol, precision: 2, format: "%u %n"
  end

  def number_to_reports_credit(number, credit = nil)
    number_to_currency number, unit: credit&.symbol || "Credits", precision: 2
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
