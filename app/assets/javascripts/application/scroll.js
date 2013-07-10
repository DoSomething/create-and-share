$(document).ready(function() {
  var page = 0;     // Default page
  var running = 10; // How many posts are currently shown
  var done = [];

  function in_view() {
    $('.inview').bind('inview', function(event, visible) {
      if (count <= 10) {
        $('.inview').remove();
        return false;
      }

      // Page + 1
      page++;

      // If we are viewing a filter...
      if (typeof filter != 'undefined') {
          $.getScript('/' + filter + '.js?page=' + page + '&last=' + latest, function() {
            // Remove the current inview element.  Add a new one.
            $('.inview').remove();
            $('<div></div>').addClass('inview').appendTo($('.post-list'));

            // Reload Facebook click event
            load_facebook();
            // Running count += returned count
            running += returned;
            // Only keep going if there are more posts to show.
            if (running < count) {
              in_view();
            }
            else {
              $('.inview').remove();
            }
          });
      }
      else {
        $.getScript('/posts.js?page=' + page + '&last=' + latest, function() {
          // Remove the current inview element.  Add a new one.
          $('.inview').remove();
          $('<div></div>').addClass('inview').appendTo($('.post-list'));

          // Load Facebook
          load_facebook();
          // Running count += returned count
          running += returned;
          // Only keep going if there are more posts to show.
          if (running < count) {
            in_view();
          }
          else {
            $('.inview').remove();
          }
        });
      }
    });
  }

  // Go.
  in_view();
});