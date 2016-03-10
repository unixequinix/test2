function showPaymentMethod() {
  var trigger = $(".btn-payment-trigger"),
      html = $("html"),
      body = $("body");

  trigger.on("click", function(event) {
    var target = this.dataset.target;

    $("#method-" + target).toggleClass("show-container").siblings(".container-method").removeClass("show-container");
    $(this).toggleClass("button-selected").siblings().removeClass("button-selected");
  });

};

$(document).on("page:load", showPaymentMethod);
$(document).ready(showPaymentMethod);
