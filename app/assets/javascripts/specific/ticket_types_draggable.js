function ticket_types_draggable_table() {
    var action;

    $('#ticket_type_action').change(function() {
        action = this.value;
    });

    draggableTableElems({
        sortableItems: 'table > tbody > *',
        referenceParent: '#delete_ticket_type_table',
        inputSelector: 'td.table-actions div.table-action input',
        callback: function(form, ids) {
            $.ajax({
                type: form.attr('_method'),
                url:  form.attr('action'),
                dataType: 'script',
                data: {
                    station: {ticket_type_ids: ids}
                },
                success: function(rest) {
                    componentHandler.upgradeAllRegistered();
                }
            });
        },
    });
};
