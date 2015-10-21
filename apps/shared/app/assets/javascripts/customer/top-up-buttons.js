function topUpButton() {

  if( $(".product-amount").length > 0 ) {

    $(function() {
      FastClick.attach(document.body);
    });

    $('.amount-button').on('click',function(){
      var inputId = $(this).data('id');
      var price = $(this).data('price');
      var step = $(this).data('step');
      var input = $('#amount-input-' + inputId);
      var total = $('#amount-total-' + inputId);
      var min = input.attr('min');
      var max = input.attr('max');
      var amount = $(this).data('operation') == "plus" ? parseInt(input.val())+step : parseInt(input.val())-step;
      if (amount >= min && amount <= max) {
        input.val(amount);
        total.text((amount * price));
      }
    });

    $('.amount-input').on('change',function(){
      var inputId = $(this).data('id');
      var price = $(this).data('price');
      var amount = $(this).val();
      var total = $('#amount-total-' + inputId);
      total.text((amount * price));
    });
  }
};

$(document).on('page:load', topUpButton);
$(document).ready(topUpButton);
