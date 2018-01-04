function device_registration_draggable_table() {
  var action; 

  $('#device_registration_action').change(function() {
    action = this.value;
  });

  draggableTableElems({
    sortableItems: 'table > tbody > *', 
    referenceParent: '#delete_devices_table',
    inputSelector: 'td.table-actions div.table-action input',
    callback: function(form, ids) {
                $.ajax({
                  type: form.attr('_method'),
                  url:  form.attr('action'),
                  dataType: 'script',
                  data: { 
                    device_registration: {
                      device_ids: ids,
                      initialization_type: action
                    }
                  },
                  success: function(rest) {
                    componentHandler.upgradeAllRegistered();
                  }
                });
              },  
  });
};
