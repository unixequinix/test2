function showPaymentMethod() {
  var triggers = $(".btn-payment-trigger");

  triggers.on("click", function(event) {
    var target = this.dataset.target;

    $(this).toggleClass("button-selected");

    triggers.not(this).removeClass("button-selected");

    $("#method-" + target).toggleClass("show-container").siblings(".container-method").removeClass("show-container");
  });
};

$(document).on("page:load", showPaymentMethod);
$(document).ready(showPaymentMethod);
