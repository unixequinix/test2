function SideMenu() {

  if ( $('#search-menu').length ) {
    $("#search-menu").mmenu({
      "offCanvas": {
         "position": "right"
      }
    });
  }
  if ( $('#import-menu').length ) {
    $("#import-menu").mmenu({
      "offCanvas": {
         "position": "right"
      }
    });
  }
};

$(document).on('page:load', SideMenu);
$(document).ready(SideMenu);