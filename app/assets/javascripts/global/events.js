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
});
