function UpdateFlagFormValue() {
//  if( $("#registration_parameters").length > 0 ) {
  $(".flag-selector").change(function() {
    checkboxGroup = $(this).data("checkbox-group");
    var eventParameters = $("#event_"+checkboxGroup);
    var eventValue = eventParameters.attr("value");
    if(!$(this).is(':checked')) {
        eventParameters.attr("value", +eventValue - +$(this).attr("value"));
    } else {
        eventParameters.attr("value", +eventValue + +$(this).attr("value"));
    }
  });
//  }
}
$(document).on('page:load', UpdateFlagFormValue);
$(document).ready(UpdateFlagFormValue);
