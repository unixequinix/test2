function SideMenu() {

  if ( $('#main-menu').length ) {
    $("#main-menu").mmenu();
  }
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
}
$(document).on('turbolinks:load', SideMenu);
$(document).ready(SideMenu);