function DeleteAll() {

  if( $("#select-all").length > 0 ) {
    $('#select-all').change(function() {
      var checkboxes = $(this).closest('form').find(':checkbox');
      if($(this).is(':checked')) {
          checkboxes.prop('checked', true);
      } else {
          checkboxes.prop('checked', false);
      }
    });
  }
}
$(document).on('turbolinks:load', DeleteAll);
$(document).ready(DeleteAll);
