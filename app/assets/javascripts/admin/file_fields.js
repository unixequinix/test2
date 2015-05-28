function FileField() {
  $('#sendButton').prop('disabled',true);
  $('#file').on('change', function(){
    $('#sendButton').prop('disabled', this.value == "" ? true : false);
  });
};

$(document).on('page:load', FileField);
$(document).ready(FileField);
