function canvasToPDF(elem, fileName, eventData) {
  var options = {
    height: $(elem).height() + 300,
    onclone: function(document) {
      function subtitleElemConstructor(text, value) { var text = "<div><span class='title'>" + text + "</span><span>" + value + "</span></div>"; return text };

      var titleContainer = "<div class='mdl-cell mdl-cell--12-col mld-card analytics-card-back'><div class='mdl-grid' id='report-title'></div></div>"
      var subtitleContainer = "<div class='mdl-cell mdl-cell--5-col pdf' id='report-subtitle'></div>"
      var footerContainer = "<div class='mdl-cell mdl-cell--12-col'><div class='mdl-cell mdl-cell--12-col pdf' id='report-footer'></div></div>"
      var titleElem = "<div class='mdl-cell mdl-cell--7-col pdf'><div class='mdl-cell mdl-cell--12-col mld-card'><div class='mdl-grid'><div class='mdl-cell mdl-cell--6-col mld-card'><image src='" + eventData.logo_url + "'/></div><div class='mdl-cell mdl-cell--6-col mld-card'><h3 class='title'>" + eventData.name + "</h3></div></div></div>"
      var footerElem = "<div class='footer'><p>Data shown here is provisional until the event is closed, all device are synced & locked, and the event data is fully wrapped.</p></div>"

      var subtitleContent = [
        subtitleElemConstructor("Event start date: ", new Date(eventData.start_date)),
        subtitleElemConstructor("Event end date: ", new Date(eventData.end_date)),
        subtitleElemConstructor("Report download time: ", new Date(Date.now())),
        subtitleElemConstructor("Support email: ", eventData.support_email),
      ]

      $(document).find(elem.selector).prepend(titleContainer);
      $(document).find(elem.selector).prepend(footerContainer);
      $(document).find('#report-footer').append([footerElem]);
      $(document).find('#report-title').append([titleElem, subtitleContainer]);
      $(document).find('#report-subtitle').append(subtitleContent);
    }
  };

  html2canvas($(elem)[0], options).then(function(canvas) {
    var doc = new jsPDF('p', 'mm', 'a4');
    var imgData = canvas.toDataURL('image/png');

    // Adjust width and height in mm
    var pageHeight = 295;
    var imgWidth = 210;
    var imgHeight = canvas.height * imgWidth / canvas.width;
    var heightLeft = imgHeight;
    var xPosition = 0;
    var yPosition = 2;

    doc.addImage(imgData, 'PNG', xPosition, yPosition, imgWidth, imgHeight);
    heightLeft -= pageHeight;

    while (heightLeft >= 0) {
      yPosition = heightLeft - imgHeight;
      doc.addPage();
      doc.addImage(imgData, 'PNG', xPosition, yPosition, imgWidth, imgHeight);
      heightLeft -= pageHeight;
    }

    doc.save(fileName + ".pdf");
}).catch(function(e) {
    console.log(e);
  });
};
