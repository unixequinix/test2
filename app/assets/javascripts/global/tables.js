$(document).on("ready", function(){

  $(function(){
    var classes = document.querySelectorAll(".expanf")
    $('tr').hover(function(){ /* hover first argument is mouseenter*/
        $(this).find('button').css({"visibility": "visible"});
    },function(){  /* hover second argument is mouseleave*/
       $(this).find('button').css({"visibility": "hidden"});
    });
  });

  $(function hideElements(){
    $('#hide').click(function(){
      var myElements = document.querySelectorAll(".is-selected");
      for (var i = 0; i < myElements.length; i++) {
        myElements[i].className += " hiding";
      }
    });
  });

  $(function showElements(){
    $('#hide').click(function(){
      var myElements = document.querySelectorAll(".is-selected");
      for (var i = 0; i < myElements.length; i++) {
        myElements[i].className += " hiding";
      }
    });
  });

});

