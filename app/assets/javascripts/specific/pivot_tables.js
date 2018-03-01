function setTable(data, rows, cols, metric, decimals, chartId, title, renderers, sum, frFormat) {
  $(chartId).pivot(data, {
    renderers: renderers,
    cols: cols,
    rows: rows,
    aggregator: sum(frFormat)(metric)
  });
}

function setPivotTable(data, rows, cols, metric, decimals, chartId, title, renderers, sum, frFormat, type, show) {
  $(chartId + show).pivotUI(data, {
    renderers: renderers,
    cols: cols, rows: rows,
    rendererName: type,
    aggregators: { ["metric"]: function () { return sum(frFormat)(metric) } },
  });
}

function exportCSV(tableId, title) {
  var text = $("#" + tableId + " td.pvtRendererArea textarea").text();
  var hiddenElement = document.createElement('a');
  hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(text);
  hiddenElement.target = '_blank';
  hiddenElement.download = title + '.tsv';
  hiddenElement.click();
};

function exportTSV(tableId, title) {
  $(".pvtRenderer:first").val("TSV Export").trigger("change");
  var checkExist = setInterval(function() {
     if ($(tableId).length) {
        var text = $(tableId).text();
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(text);
        hiddenElement.target = '_blank';
        hiddenElement.download = title + '_pivot_data.tsv';
        hiddenElement.click();
        clearInterval(checkExist);
        $(".pvtRenderer:first").val("Table").trigger("change");
     }
  }, 100);
};

function exportRawData(data, title) {
  var fields = Object.keys(data[0])
  var replacer = function(key, value) { return value === null ? '' : value }
  var csv = data.map(function(row){
    return fields.map(function(fieldName){
      return JSON.stringify(row[fieldName], replacer)
    }).join(';')
  })
  csv.unshift('\"' + fields.join('";"') + '\"')
  csv = csv.join('\r\n');
  var hiddenElement = document.createElement('a');
  hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
  hiddenElement.target = '_blank';
  hiddenElement.download = title + '_raw_data.csv';
  hiddenElement.click();
};
