module EventsHelper
  def best_in_place_checkbox(url)
    yes = content_tag :div, "radio_button_checked", class: "material-icons"
    no = content_tag :div, "radio_button_unchecked", class: "material-icons"
    { collection: { false: no, true: yes }, place_holder: no, as: :checkbox, url: url }
  end
end
