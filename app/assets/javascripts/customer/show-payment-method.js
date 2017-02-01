function showPaymentMethod() {
  var triggers = $(".btn-payment-trigger"),
      doc = $(document);

  triggers.on("click", function(event) {
    var target = this.dataset.target;

    doc.scrollTop( $("#payment-anchor").offset().top );
    triggers.not(this).removeClass("button-selected");
    $(this).toggleClass("button-selected");
    $("#method-" + target).toggleClass("show-container").siblings(".container-method").removeClass("show-container");
  });

}
$(document).on("turbolinks:load", showPaymentMethod);

