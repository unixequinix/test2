function showNavMobile() {
  var trigger = $(".mobile-trigger");

  trigger.on("click", function(event){
    $('#mobile-options').toggleClass('open-nav');
  });
};

$(document).on('page:load', showNavMobile);
$(document).ready(showNavMobile);



