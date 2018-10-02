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
    var table = $("table.sortable");
    customSortable(table);
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

function multipleSelect(selector) {
  var table = $("#" + selector);
  $(table).change(function(e) {
    var selected = e.originalEvent.srcElement.id.includes('_all_checkboxes') ? $(e.currentTarget).find('tr:not(:first):not(.ui-state-disabled)') : $(e.originalEvent.srcElement);
    selected.each(function(i, elem) {
      var input = $(elem).find('td.table-actions div.table-action input');
      if(input[0] == undefined) return;
      if(input[0].checked) {
        input.prop('checked', false);
        input.closest('label').removeClass('is-checked');
      } else {
        input.prop('checked', true);
        input.closest('label').addClass('is-checked');
      };
    });
  });

  customSortable(table);
}

function customSortable(table, iconText) {
  var iconText = iconText ? iconText : "import_export";
  var icon = $("<i class='material-icons'></i>").text(iconText);
  table.tablesorter();
  table.data("sorter", false);
  table.find('.tablesorter-header-inner').each(function() {
    if(!this.parentElement.classList.value.includes('no-icon') && !$(this).find('i').length)
      this.append(icon.clone()[0])
  });
}

