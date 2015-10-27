function InputFocus() {
  $("input:text:visible:first").focus();
};

$(document).on('page:load', InputFocus);
$(document).ready(InputFocus);
