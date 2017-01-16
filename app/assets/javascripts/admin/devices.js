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
$(document).on('turbolinks:load', DeviceFilter);
$(document).ready(DeviceFilter);
