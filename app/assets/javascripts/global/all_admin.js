$(document).on("ready", function(){
  $("#delete_multiple").on("click",function(event){
    var type = $(this).data("type");
    var myElements = document.querySelectorAll(".is-selected");
    for (var i = 0; i < myElements.length; i++) {
      var elem = myElements[i];
      var eventId = $(elem).data("event");
      var itemId = $(elem).data(type);
      var url = '/admins/events/' + eventId + '/' + type + 's/' + itemId ;

      $.ajax  ({
        type: "DELETE",
        url: url,
        dataType: "json",
        async: false,
        success: function(){$(elem).fadeOut();},
        error: function(xhr){
          var obj = JSON.parse(xhr.responseText);
          var cell = $("tr[data-" + type + "='" + itemId + "'] td:nth-child(2)");
          cell.append(" " + obj["errors"]);
          cell.css('color', 'red');
          return true;
        }
      });

    }
  });


  $("#ban_multiple").on("click",function(event){
    var type = $(this).data("type");
    var myElements = document.querySelectorAll(".is-selected");
    for (var i = 0; i < myElements.length; i++) {
      var elem = myElements[i];
      var eventId = $(elem).data("event");
      var itemId = $(elem).data(type);
      var url = '/admins/events/' + eventId + '/' + type + 's/' + itemId + '/ban' ;

      $.ajax  ({
        type: "GET",
        url: url,
        dataType: "json",
        async: false,
        success: function(){ $(elem).find("a .material-icons").html("radio_button_checked"); }
      });

    }
  });

  $("#unban_multiple").on("click",function(event){
    var type = $(this).data("type");
    var myElements = document.querySelectorAll(".is-selected");
    for (var i = 0; i < myElements.length; i++) {
      var elem = myElements[i];
      var eventId = $(elem).data("event");
      var itemId = $(elem).data(type);
      var url = '/admins/events/' + eventId + '/' + type + 's/' + itemId + '/unban' ;

      $.ajax  ({
        type: "GET",
        url: url,
        dataType: "json",
        async: false,
        success: function(){ $(elem).find("a .material-icons").html("radio_button_unchecked"); }
      });

    }
  });
});

