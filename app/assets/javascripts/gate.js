// GATE
// -----
$(function() {
  var $toggle_form = $('#toggle-form');

  $toggle_form.click(function() {
    var $this = $(this);
    var $this_text = $this.text();

    var $login = $('#login-form');
    var $register = $('#registration-form');

    if($this_text === 'register') {
      $this.text('login');
      $register.show();
      $login.hide();
    }
    else if($this_text === 'login' ) {
      $this.text('register');
      $login.show();
      $register.hide();
    }
  });

  // END
});

