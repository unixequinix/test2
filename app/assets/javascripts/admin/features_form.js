function UpdateFlagFormValue() {

  if( $("#features").length > 0 ) {
    $(".flag-selector").change(function() {
      var event_features = $("#event_features");
      var event_value = event_features.attr("value");
      if(!$(this).is(':checked')) {
          event_features.attr("value", +event_value - +$(this).attr("value"));
      } else {
          event_features.attr("value", +event_value + +$(this).attr("value"));
      }
    });
  }
};

$(document).on('page:load', UpdateFlagFormValue);
$(document).ready(UpdateFlagFormValue);
