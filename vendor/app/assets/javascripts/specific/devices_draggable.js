function loadTable(tableId, data) {
	device_draggable_table(tableId, function (form, ids) {
		$.ajax({
			type: form.attr('_method'),
			url: form.attr('action'),
			dataType: 'script',
			data: data(form, ids)
		}).done(function( msg ) {
			componentHandler.upgradeAllRegistered();
		});;
	})
}

function device_draggable_table(tableId, callback) {
	var jsonStruct = jsonStruct || {};
	
	draggableTableElems({
		sortableItems: 'table > tbody > tr:not(.ui-state-disabled)',
		referenceParent: "#" + tableId,
		inputSelector: "td.table-actions div.table-action input:not(.ui-state-disabled)",
		cancel: ".ui-state-disabled",
		callback: callback
	});
}