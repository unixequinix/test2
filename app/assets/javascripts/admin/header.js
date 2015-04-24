$(document).ready(function() {

  var $menu = $(".submenu-list");

  $('.submenu-trigger').on('click', function(e) {

    $menu.toggleClass("open"); //you can list several class names
  });

});