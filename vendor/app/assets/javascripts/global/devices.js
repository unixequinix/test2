function DeviceFilter() {

  if( $("#js-device-filter").length > 0 ) {
    $('#js-device-filter').change(function() {
      if(this.selectedIndex != 0) {
        window.location = "/admins/devices?filter=" + $(this).val()
      } else {
        window.location = "/admins/devices"
      }
    });
  }
}
$(document).on('page:load', DeviceFilter);
$(document).ready(DeviceFilter);


$(document).on("ready", function(){

  $(".focus").on("click",function(event){
    var $button = $(event.currentTarget);
    var device = $button.data("device");

    $("." + device).toggle();
  });

});
