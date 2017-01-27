$(document).on("ready", function(){
  document.addEventListener('mdl-componentupgraded', function(e) {
    //In case other elements are upgraded before the layout
    if (typeof e.target.MaterialLayout !== 'undefined') {
        tinymce.init({
          selector: '.textarea',
          inline: false,
          resize: 'both',
          menubar: false,
          statusbar: false,
          body_class: 'text-body',
          content_css: ["/assets/default.css"]
        });
        tinymce.init({
          selector: '.cssarea',
          inline: false,
          resize: 'both',
          menubar: false,
          statusbar: false,
          toolbar: false,
          body_class: 'mce-body',
          content_css: ["/assets/default.css"],
        });
    }
  });

  document.getElementById("uploadBackground").onchange = function () {
      document.getElementById("uploadB").value = this.files[0].name;
  };

  document.getElementById("uploadLogo").onchange = function () {
      document.getElementById("uploadL").value = this.files[0].name;
  };
});

