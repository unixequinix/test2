function showPaymentMethod() {
  var trigger = $(".payment-trigger"),
      html = $("html")
      body = $("body");

  trigger.on("click", function(event) {
    event.preventDefault();
    event.stopPropagation();
    var target = this.dataset.target;

    console.log(target);
    $(".container-method").removeClass("show-container");
    $("#method-" + target).toggleClass("show-container");
  });
};

$(document).on("page:load", showPaymentMethod);
$(document).ready(showPaymentMethod);

