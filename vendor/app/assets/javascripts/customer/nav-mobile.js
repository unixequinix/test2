function showNavMobile() {
  var trigger = $("#mobile-trigger"),
    triggerIcon = $('.mobile-trigger i'),
    target = $('#mobile-options'),
    unscrollableContent = $('.container-main'),
    close = $('.mobile-options');

  trigger.on("click", function(event) {
    triggerIcon.toggleClass('fa-times');
    target.toggleClass('open-nav');
    unscrollableContent.toggleClass('unscrollable-view');
  });

  close.on("click", function() {
    target.removeClass('open-nav');
    unscrollableContent.removeClass('unscrollable-view');
    triggerIcon.toggleClass('fa-times');
  });
}

$(document).ready(showNavMobile);