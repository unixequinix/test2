$(document).on("ready", function(){

  $("#deletegtag").on("click",function(event){
    var myElements = document.querySelectorAll(".is-selected");
    for (var i = 0; i < myElements.length; i++) {
      var eventId = $(myElements[i]).data("event");
      var gtagId = $(myElements[i]).data("gtag");
      var url = '/admins/events/' + eventId + '/gtags/' + gtagId ;
      $(myElements[i]).fadeOut("normal", function() {
        $(this).remove();
      });

      $.ajax({
        type: "DELETE",
        url: url,
        dataType: "json",
        success: function(){
          console.log("right");
        },
        error: function(err){
          console.log("wrooooong \n");
          console.log(err);
        }
      });

    }
  });

});
