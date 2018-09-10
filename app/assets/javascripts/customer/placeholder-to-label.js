function placeholderToLabel() {
  var target = $("input");

  target.each(function() {
    if (this.value || $(this).is(":focus")) {
      $(this).prev().addClass("to-be-label");
    }

    $(this).on("focus", function(event) {
      $(this).prev().addClass("to-be-label");
    });

    $(this).on("blur", function(event) {
      $(this).prev().removeClass("to-be-label");
      if (this.value) {
        $(this).prev().addClass("to-be-label");
      }
    });
  });
}

$(document).ready(placeholderToLabel);