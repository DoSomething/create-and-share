// GATE
// -----
$(function() {
  var $toggle_form = $('#toggle-form');

  toggle = function(elm, text) {
    elm.text((text == 'register' ? 'log in' : 'register'));
    $('.headline').text(text);
    $('#login-form, #registration-form').toggle();
  };

  $toggle_form.click(function() {
    var $this = $(this);
    var $this_text = $this.text();

    toggle($this, $this_text);
  });

  // END
});

