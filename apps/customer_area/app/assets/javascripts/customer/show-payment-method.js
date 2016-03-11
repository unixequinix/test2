function showPaymentMethod() {
  //var tempScrollTop = $(window).scrollTop();
  var triggers = $(".btn-payment-trigger");

  triggers.on("click", function(event) {
    var target = this.dataset.target;

    //// TODO Remove animate!!!
    //$('html, body').animate({
    //    scrollTop: $('.container-method').offset().top
    //}, 'slow');
    //$(".container-method").find('input').focus();

    triggers.not(this).removeClass("button-selected");
    $(this).toggleClass("button-selected");
    $("#method-" + target).toggleClass("show-container").siblings(".container-method").removeClass("show-container");
  });

  //$(window).scrollTop(tempScrollTop);

};

$(document).on("page:load", showPaymentMethod);
$(document).ready(showPaymentMethod);
