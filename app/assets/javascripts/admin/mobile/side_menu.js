function SideMenu() {

if ( $('#main-menu').length ) {
    $("#main-menu").mmenu();
  }
};

$(document).on('page:load', SideMenu);
$(document).ready(SideMenu);

