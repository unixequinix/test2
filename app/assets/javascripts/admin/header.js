function SetupHeader() {

  var $menu = $("#submenu-list");

  $('#submenu-trigger').on('click', function(e) {
     e.stopPropagation();
     e.preventDefault();

    $menu.toggleClass("open"); //you can list several class names

    $('html').one('click', function() {
      $menu.removeClass('open');
    });
  });
}
$(document).on('turbolinks:load', SetupHeader);
$(document).ready(SetupHeader);

