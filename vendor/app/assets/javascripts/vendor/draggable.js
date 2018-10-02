function draggableTableElems (attr) {
  sortableContainer = attr['sortableContainer'] || '';
  sortableItems = attr['sortableItems'] || '';
  referenceParent = attr['referenceParent'] || '';
  inputSelector = attr['inputSelector'] || '';
  callback = attr['callback'] || 'undefined';
  
  this.baseForm;

  $.each($('table.droppable' + sortableContainer), function(i, table) {
    if(!$(table).find('tbody').length) {
      table.appendChild(document.createElement('tbody'));
    }
  });

  $('table.droppable' + sortableContainer).sortable({
    cancel: 'td span',
    revert: 300,
    dropOnEmpty: true,
    connectWith: "table.droppable",
    items: $(sortableItems),
    appendTo: $(referenceParent).find('tbody'),
    helper:"clone",
    cursor:"move",
    zIndex: 9999,
    start: function(event, ui) { self.baseForm = $(this).closest('form'); }
  });

  $('table.droppable' + sortableContainer).droppable({
    tolerance: 'touch',
    drop: function(event, ui) {
      var destinationForm = $(event.target).closest('form');
      
      if (destinationForm[0] == self.baseForm[0]) {
        return false
      } else {
        var ids = [];
        
        $.each(ui.draggable, function(i, elem) {
          $(elem).detach().appendTo(destinationForm.find('tbody')[0]);
          ids.push($(elem).find(inputSelector)[0].value);

          componentHandler.upgradeDom('table.droppable')
        }.bind(destinationForm));

        
        if (callback != 'undefined'){
          callback(self.baseForm, ids);
        };
      }
    }
  });
};
