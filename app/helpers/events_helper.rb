module EventsHelper
  def best_in_place_checkbox(url)
    yes = render "layouts/checkbox_yes"
    no = render "layouts/checkbox_no"
    { collection: { false: no, true: yes }, place_holder: no, as: :checkbox, url: url }
  end
end
