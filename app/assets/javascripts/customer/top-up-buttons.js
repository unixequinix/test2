function calculateTotalCheckout () {
  var calculatedTotal = 0,
      product = null;
  $('.amount-input').each(function(idx, element) {
    product = $(element);
    calculatedTotal += product.data('price') * product.val();
  });
  $('#amount-total-checkout').text(calculatedTotal);
  $('#show-money').text(calculatedTotal);
}

function topUpButton() {

  if( $("#checkout-form").length > 0 ) {

    $(function() {
      FastClick.attach(document.body);
      calculateTotalCheckout();
    });

    $('.amount-button').on('click',function(){
      var $this = $(this),
          inputId = $this.data('id'),
          price = $this.data('price'),
          step = $this.data('step'),
          input = $('#amount-input-' + inputId),
          total = $('#amount-total-' + inputId),
          min = input.attr('min'),
          max = input.attr('max'),
          amount = $this.data('operation') == "plus" ? parseInt(input.val())+step : parseInt(input.val())-step;

      if (amount >= min && amount <= max) {
        input.val((amount));
        total.text((amount * price));
      }
      calculateTotalCheckout();
    });

    $('.amount-input').on('change',function(){
      var $this = $(this),
          inputId = $this.data('id'),
          price = $this.data('price'),
          amount = $this.val(),
          total = $('#amount-total-' + inputId);

      total.text((amount * price));
      calculateTotalCheckout();
    });

    $('#input-range').bind('input', function(){
    	calculateTotalCheckout();
    }).bind('change', function(){
    	calculateTotalCheckout();	/* IE */
    });
  }
}

$(document).on('turbolinks:load', topUpButton);



