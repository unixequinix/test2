function SideMenu() {

  if ( $('#main-menu').length ) {
    $("#main-menu").mmenu();
  }
  if ( $('#import-menu').length ) {
    $("#import-menu").mmenu({
      offCanvas: {
        position: "right"
      }
    });
  }
};

$(document).on('page:load', SideMenu);
$(document).ready(SideMenu);

$(document).ready(function() {
      $("#search-menu").mmenu({
         offCanvas: {
            position: "right"
         }
      });
   });