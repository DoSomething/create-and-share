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

  set_votes = function() {
    // THUMBS UP & THUMBS DOWN
    // $('.thumbs-up, .thumbs-down').click(function(e) {
    //   if (user.id == 0) {
    //     $('<div id="please-log-in">Please <a href="/' + campaign.path + '/login">log in or register</a> to vote on posts.</div>').dialog({
    //       dialogClass: 'please-log-in',
    //       minHeight: '250px',
    //       width: '350px',
    //       close: function() {
    //         $('#please-log-in').remove();
    //       }
    //     });

    //     return false;
    //   }

    //   if (!campaign.allow_revoting && $(this).hasClass('shared')) {
    //     return false;
    //   }

    //   e.preventDefault();
    //   var type = $(this).data("type");
    //   var id = $(this).parent().parent().data("id");
    //   var post = '.post[data-id="' + id + '"] ';

    //   if (!campaign.allow_revoting) {
    //     $(post + ' .thumbs-up, ' + post + ' .thumbs-down').addClass('shared');
    //   }

    //   $.post('/' + campaign.path + '/posts/' + id + '/thumbs',
    //     { type: type },
    //     function(response) {
    //       $(post + '.count').text(response["score"]);
    //       $(post + '.thumbs-up-count').text(response["up"]);
    //       $(post + '.thumbs-down-count').text(response["down"]);
    //       $(post + '.thumbs-up, ' + post + '.thumbs-down').removeClass("voted");
    //       if (response["color"]) {
    //         $(post + '.thumbs-' + type).addClass("voted");
    //       }
    //       render_popup(response["popup"]);
    //   });
    // });

    // if (!(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))) {
    //   $('.thumbs-up, .thumbs-down').mouseover(function() {
    //     var type = $(this).data("type");
    //     var id = $(this).parent().parent().data("id");
    //     var post = '.post[data-id="' + id + '"] ';
    //     $(post + '.thumbs-' + type + '-count-wrapper').css({ visibility: "visible" });
    //   }).mouseout(function() {
    //     var type = $(this).data("type");
    //     var id = $(this).parent().parent().data("id");
    //     var post = '.post[data-id="' + id + '"] ';
    //     $(post + '.thumbs-' + type + '-count-wrapper').css({ visibility: "hidden" });
    //   });
    // }

    // if (!campaign.allow_revoting) {
    //   if (typeof user.votes === 'object') {
    //     for (var i in user.votes) {
    //       $('.id-' + user.votes[i] + ' .thumbs-up').addClass('shared');
    //       $('.id-' + user.votes[i] + ' .thumbs-down').addClass('shared');
    //     }
    //   }
    // }
  };

  $(document).ready(function() {
    if (typeof campaign !== 'undefined') {
      $('img.lazy').lazyload();
      // set_votes();
    }
  });
});
