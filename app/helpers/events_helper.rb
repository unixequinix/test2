module EventsHelper
  def best_in_place_checkbox(url)
    yes = content_tag :i, "done", class: "material-icons"
    no = content_tag :div, "clear", class: "material-icons"
    { collection: { false: no, true: yes }, place_holder: no, as: :checkbox, url: url }
  end
end
