function showPurchasesTreeHints() {
  var hint = $(".hint-purchase"),
      container = $(".container-purchase-order");

  if ($(".purchase-list-item").length > 0) {
    hint.addClass("show");
    container.addClass("show");
  };
};

$(document).on('page:load', showPurchasesTreeHints);
$(document).ready(showPurchasesTreeHints);
