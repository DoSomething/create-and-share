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
        'link': document.location.origin + '/' + settings['id'],
        'name': campaign.facebook.title || '',
        'caption': campaign.facebook.caption || '',
        'description': campaign.facebook.description || '',
        'picture': settings['picture']
      }, function(response) {
        if (response && response.post_id) {
          var new_count = ++settings['share_count'];
          settings['share_elm'].text(new_count);
          $.post('/' + campaign.path + '/shares', { 'share': { 'post_id': settings['id'] }, 'new_count': new_count }, function(res) {
            render_popup(response["popup"]);
          });
        }
        $('html,body').animate({ scrollTop: $('.id-' + settings['id']).offset().top }, 'fast');
      });
    }
  });

  // POPUPS
  render_popup = function(popup) {
    if(popup != "") {
      var overlay = $("<div class='popup-overlay'></div>")
      overlay.appendTo("body");
      var container = $("<div class='popup-container'></div>")
      container.appendTo("body");
      container.load('/' + campaign.path + '/popups/' + popup + " #popup", function() {
        var close = $("<div class='popup-close'>x</div>")
        close.appendTo(container);
        close.click(function() {
          overlay.remove();
          container.remove();
        });
      });
    }
  }

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

  // THUMBS UP & THUMBS DOWN
  $('.thumbs-up, .thumbs-down').click(function(e) {
    e.preventDefault();
    var type = $(this).data("type");
    var id = $(this).parent().parent().data("id");
    $.post('/' + campaign.path + '/posts/' + id + '/thumbs',
      { type: type },
      function(response) {
        var post = '.post[data-id="' + id + '"] '
        $(post + '.count').text(response["score"]);
        $(post + '.thumbs-up-count').text(response["up"]);
        $(post + '.thumbs-down-count').text(response["down"]);
        $(post + '.thumbs-up, ' + post + '.thumbs-down').removeClass("voted");
        if(response["color"])
          $(post + '.thumbs-' + type).addClass("voted");
        render_popup(response["popup"]);
    });
  }).mouseover(function() {
    var type = $(this).data("type");
    var id = $(this).parent().parent().data("id");
    var post = '.post[data-id="' + id + '"] '
    $(post + '.thumbs-' + type + '-count-wrapper').css({ visibility: "visible" });
  }).mouseout(function() {
    var type = $(this).data("type");
    var id = $(this).parent().parent().data("id");
    var post = '.post[data-id="' + id + '"] '
    $(post + '.thumbs-' + type + '-count-wrapper').css({ visibility: "hidden" });
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

  $(document).ready(function() {
    $('img.lazy').lazyload();
  });
  // END
});
