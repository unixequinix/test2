function navMobile() {
  $('.mobile-trigger').on('click', function(){
      $('.mobile-list').toggleClass('opened')
  });
};

$(document).on('page:load', navMobile);
$(document).ready(navMobile);