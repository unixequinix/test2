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

  $(function sortTableColumns(){
    $("table.sortable").tablesorter(); 
  });

  $('.collapse-link-closed').click(function () {
      var card = $(this).closest('div.admin-card-wide');
      var button = $(this).find('i');
      var content = card.find('div.table-responsive');
      content.slideToggle(200);
      button.toggleClass('fa-chevron-down').toggleClass('fa-chevron-up');
      card.toggleClass('').toggleClass('border-bottom');
      setTimeout(function () {
          card.resize();
          card.find('[id^=map-]').resize();
      }, 50);
  });

});

