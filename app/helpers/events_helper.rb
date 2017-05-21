module EventsHelper
  def best_in_place_checkbox(url)
    yes = content_tag :span, "done", class: "icon material-icons"
    no = content_tag :span, "clear", class: "icon material-icons"
    { collection: { false: no, true: yes }, place_holder: no, as: :checkbox, url: url }
  end
end
