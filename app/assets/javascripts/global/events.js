$(document).on("ready", function(){

 $(".change-state").on("click",function(event){
   var $button = $(event.currentTarget);
   var newState = $button.data("state");
   var eventId = $button.data("id");

   var url = '/admins/events/' + eventId ;
   var newState = { 'state': newState };

    $.ajax({
      type: "PUT",
      url: url,
      dataType: "json",
      data: {event: newState},
      success: function(){
        $button.is(':checked');
        console.log("right");
      },
      error: function(err){
        console.log("wrooooong \n");
        console.log(err);
      }
    });
 });

 $("#deleteaccess").on("click",function(event){
   var myElements = document.querySelectorAll(".is-selected");
   for (var i = 0; i < myElements.length; i++) {
     var accessId = $(myElements[i]).data("access");
     var eventId = $(myElements[i]).data("event");
     var url = '/admins/events/' + eventId + '/accesses/' + accessId ;
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
