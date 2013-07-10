// POSTS
// -----
$(function() {
  // INITIALIZE FRIEND SELECTOR
  TDFriendSelector.init();

  friendselector = TDFriendSelector.newInstance({
    maxSelection: 1,
    autoDeselection: true,
    friendsPerPage: 7,
    callbackSubmit: function(selected, settings) {
      friend = parseInt(selected[0]);

      FB.ui({
        'to': friend,
        'method': 'feed',
        'link': 'http://pics.dosomething.org/' + settings['id'],
        'name': 'Want to adopt me?',
        'caption': 'Pics for Pets',
        'description': settings['name'] + ' is super cute and deserves a loving home.  Could you be ' + settings['name'] + '\'s new owner?',
        'picture': settings['picture']
      }, function(response) {
        if (response && response.post_id) {
          var new_count = ++settings['share_count'];
          settings['share_elm'].text(new_count);
          $.post('/shares', { 'share': { 'post_id': settings['id'] }, 'new_count': new_count }, function(res) {});
        }
        $('html,body').animate({ scrollTop: $('.id-' + settings['id']).offset().top }, 'fast');
      });
    }
  });

  // AUTOMATICALLY FORM IMAGE SIZE ON RESIZE
  maintain_ratio = function(target) {
    $target = $(target);
    $target.height($target.width());
    $(window).resize(function(){
      $target.height($target.width());
    });
  };
  maintain_ratio('#upload-preview');

  // AUTOMATICALLY RESIZE BTN WIDTHS
  set_width = function(parent, child, width) {
    $(parent).each(function() {
      var $this = $(this);
      var child_width = $this.find(child).width() * width;
      $this.css('width', child_width);
    });
  };

  // ABSTRACTS FACEBOOK CLICK FOR INFINITE SCROLL
  load_facebook = function() {
    handle_facebook_click = function(elm, e) {
      var $id = elm.attr('data-id');
      var $name = elm.parent().parent().find('span.name').text();
      var $picture = document.location.origin + elm.parent().parent().find('img').attr('src');
      var $share_count = parseInt(elm.parent().find('.share-count').text());
      var $share_elm = elm.parent().find('.share-count');

      e.preventDefault();
      friendselector.showFriendSelector({
        'id': $id,
        'name': $name,
        'picture': $picture,
        'share_count': $share_count,
        'share_elm': $share_elm
      });
    };

    var $fbid;
    // Remove previous click event
    $('.facebook-share').unbind('click');
    $('.facebook-share').click(function(e) {
      $fbid = FB.getUserID();
      if ($fbid == "") {
        FB.login(function(response) {
          if (response.authResponse) {
            self.handle_facebook_click($(this), e);
          }
        }, { 'scope': 'email,user_birthday' });

        return false;
      }

      self.handle_facebook_click($(this), e);
    });
  };

  set_width('a.btn', 'span', 1.3);

  // SHOW & HIDE DEBUG INFORMATION
  $debug = $('.debug');
  $debug.hide();

  $('#debug').unbind('click').click(function() {
    $debug.slideToggle('fast');
    return false;
  });

  // FACEBOOK POST SHARING FUNCTIONALITY
  load_facebook();

  // PET FINDER SHELTER LOCATOR
  var $err = $('#shelter-finder .error');
  $err.hide();
  $('#shelter-submit').click(function() {
    var zip = $('#shelter-zip').val();
    var dest = 'http://www.adoptapet.com/animal-shelter-search?city_or_zip=' + zip + '&shelter_name=&distance=50&adopts_out=all';
    if (zip.match(/^\d{5}$/)) {
      $('#shelter-submit').attr('href', dest);
    }
    else {
      $err.show();
      return false;
    }
  });

  // END
});