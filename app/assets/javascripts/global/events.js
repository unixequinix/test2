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
      },
      error: function(err){
      }
    });
 });

 $('#group').change(function() {
   if( $('#group').val() ) {
     $('#station').parent().css("visibility", "hidden");
     $('#hidden-station').delay(300).show(100);

   } else {
     $('#station').parent().css("visibility", "visible");
     $('#hidden-station').hide();

   }
 });


 $('#station').change(function() {
   if( $('#station').val() ) {
     $('#group').parent().css("visibility", "hidden");
     $('#hidden-group').delay(300).show(100);

   } else {
     $('#group').parent().css("visibility", "visible");
     $('#hidden-group').hide();

   }
 });


});

