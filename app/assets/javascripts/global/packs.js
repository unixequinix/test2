$(document).on("ready", function(){

  $("#deletepack").on("click",function(event){
    var myElements = document.querySelectorAll(".is-selected");
    for (var i = 0; i < myElements.length; i++) {
      var packId = $(myElements[i]).data("pack");
      var eventId = $(myElements[i]).data("event");
      var url = '/admins/events/' + eventId + '/packs/' + packId ;
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
