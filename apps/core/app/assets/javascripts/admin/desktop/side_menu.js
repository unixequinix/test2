function SideMenu() {

  if ( $('#search-menu').length ) {
    $("#search-menu").mmenu({
      offCanvas: {
        position: "right"
      },
      navbar: {
        add: false
      }
    });
  }
};

$(document).on('page:load', SideMenu);
$(document).ready(SideMenu);
