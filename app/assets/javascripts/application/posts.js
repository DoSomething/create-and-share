// POSTS
// -----
$(function() {
  // POPUPS
  render_popup = function(popup) {
    if (popup !== "") {
      var overlay = $("<div class='popup-overlay'></div>");
      overlay.appendTo("body");
      var container = $("<div class='popup-container'></div>");
      container.appendTo("body");
      container.load('/' + campaign.path + '/popups/' + popup + " #popup", function() {
        var close = $("<div class='popup-close'>x</div>");
        close.appendTo(container);
        close.click(function() {
          overlay.remove();
          container.remove();
        });
      });
    }
  };

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
    if (!campaign.allow_revoting && $(this).hasClass('shared')) {
      return false;
    }

    e.preventDefault();
    var type = $(this).data("type");
    var id = $(this).parent().parent().data("id");
    $.post('/' + campaign.path + '/posts/' + id + '/thumbs',
      { type: type },
      function(response) {
        var post = '.post[data-id="' + id + '"] ';
        $(post + '.count').text(response["score"]);
        $(post + '.thumbs-up-count').text(response["up"]);
        $(post + '.thumbs-down-count').text(response["down"]);
        $(post + '.thumbs-up, ' + post + '.thumbs-down').removeClass("voted");
        if (response["color"]) {
          $(post + '.thumbs-' + type).addClass("voted");
          if (!campaign.allow_revoting) {
            $(post + ' .thumbs-up, ' + post + ' .thumbs-down').addClass('shared');
          }
        }
        render_popup(response["popup"]);
    });
  }).mouseover(function() {
    var type = $(this).data("type");
    var id = $(this).parent().parent().data("id");
    var post = '.post[data-id="' + id + '"] ';
    $(post + '.thumbs-' + type + '-count-wrapper').css({ visibility: "visible" });
  }).mouseout(function() {
    var type = $(this).data("type");
    var id = $(this).parent().parent().data("id");
    var post = '.post[data-id="' + id + '"] ';
    $(post + '.thumbs-' + type + '-count-wrapper').css({ visibility: "hidden" });
  });

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

    if (!campaign.allow_revoting) {
      if (typeof campaign.shares === 'object') {
        for (var i in campaign.shares) {
          $('.id-' + campaign.shares[i] + ' .thumbs-up').addClass('shared');
          $('.id-' + campaign.shares[i] + ' .thumbs-down').addClass('shared');
        }
      }
    }
  });
});
