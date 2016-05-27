function InputFocus() {
  $(".best_in_place").best_in_place();
  $("input:text:visible:first").focus();
};

$(document).on('page:load', InputFocus);
$(document).ready(InputFocus);
