$(document).on("ready", function(){

 $("#deleteadmin").on("click",function(event){
   var myElements = document.querySelectorAll(".is-selected");
   for (var i = 0; i < myElements.length; i++) {
     var adminId = $(myElements[i]).data("admin");
     var url = '/admins/admins/' + adminId ;
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
