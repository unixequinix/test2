$(document).ready(function() {
  var form = $('.form-trim');

  form.submit(function() {
    trimFields();
  });

  function trimFields() {
    var inputs = $('input[type=search]');

    inputs.each(function(i, field) {
      this.value = $.trim(field.value);
    });
  }
});
