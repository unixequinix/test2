module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, "#", class: "add_fields", data: { id: id, fields: fields.delete("\n") })
  end

  def number_to_token(number)
    number_to_currency number, unit: current_event.token_symbol.to_s + " "
  end

  def transaction_to_currency(transaction, meth)
    number = tranaction.send(meth)
    if transaction.category.eq? "money"
      number_to_currency number, unit: current_event.currency.to_s + " "
    else
      number_to_token number
    end
  end

  def title
    return "Glownet" if Rails.env == "production"
    "[#{Rails.env.upcase}] Glownet"
  end
end
