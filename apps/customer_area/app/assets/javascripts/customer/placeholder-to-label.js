function placeholderToLabel() {
  var target = $("input");

  target.each(function() {
    if( this.value ) {
      $(this).prev().addClass("to-be-label");
    };
  });

  target.blur(function(){
    $(this).prev().removeClass("to-be-label");
    if( this.value ) {
      $(this).prev().addClass("to-be-label");
    };
  });

  target.focusin(function(){
    $(this).prev().addClass("to-be-label");
  });
};

$(document).on('page:load', placeholderToLabel);
$(document).ready(placeholderToLabel);