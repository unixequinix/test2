function showPaymentMethod() {
  var triggers = $(".btn-payment-trigger");

  triggers.on("click", function(event) {
    var target = this.dataset.target;
    var fee = this.dataset.fee;
    var amount = this.dataset.amount;
    var money = this.dataset.money;
    var credits = this.dataset.credits;

    triggers.not(this).removeClass("button-selected");
    $(this).toggleClass("button-selected");
    $("#refund_fee").html(fee);
    $("#refund_amount").html(amount);
    $("#refund_money").html(money);
    $("#refund_credits").html(credits);
    $("#method-" + target).toggleClass("show-container").siblings(".container-method").removeClass("show-container");
  });

}
$(document).on("turbolinks:load", showPaymentMethod);

