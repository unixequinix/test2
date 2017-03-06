$(document).on("ready", function(){

  $(document).ready(function() { jQuery(".best_in_place").best_in_place() });

  $('.best_in_place').bind("ajax:success", function () { $(this).closest('tr').children().effect('highlight', {color: "#91ee58"}, 'slow') });
  $('.best_in_place').bind("ajax:error", function () { $(this).closest('tr').children().effect('highlight', {color: "#ff552b"}, 'slow') });

});

