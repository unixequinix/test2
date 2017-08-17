$(document).ready(function() {
  setTimeout(function() {
    $('#flash-notice').remove();
  }, 8500);
})

function move() {
  var elem = document.getElementById("bar");
  var width = 1;
  var id = setInterval(frame, 80);

  function frame() {
    if (elem) {
      if (width >= 100) {
        clearInterval(id);
      } else {
        width++;
        elem.style.width = width + '%';
      }
    }
  }
}

function closer() {
  $('#flash-notice').remove();
}

$(document).ready(move);