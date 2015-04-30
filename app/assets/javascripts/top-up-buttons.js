function TopUpButton() {

    $('.amount-button').on('click',function(){
        var inputId = $(this).data('id');
        var input = $('#amount-input-' + inputId);
        var result = $(this).data('operation') == "plus" ? parseInt(input.val())+1 : parseInt(input.val())-1;
        input.val(result);
    });
};

$(document).on('page:load', TopUpButton);
$(document).ready(TopUpButton);
