module EventsHelper
  def best_in_place_checkbox(url)
    yes = render "layouts/checkbox_yes"
    no = render "layouts/checkbox_no"
    { collection: { false: no, true: yes }, place_holder: no, as: :checkbox, url: url, activator: false } # rubocop:disable Lint/BooleanSymbol
  end

  def pretty_print_json(json_object)
    s = ""
    json_object.keys.each do |k|
      s += "Error in #{k}: #{json_object[k].first}\n"
    end
    s
  end
end
