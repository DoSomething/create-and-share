$(document).ready(function() {
  var page = 0;     // Default page
  var running = 10; // How many posts are currently shown
  var done = [];
  var returned = 0;

  function in_view() {
    $('.inview').bind('inview', function(event, visible) {
      if (count <= 10) {
        $('.inview').remove();
        return false;
      }

      // Page + 1
      page++;

      $.post('/' + campaign.path + '/posts/scroll.json', { filter: filter, type: campaign.scroll_type, page: page, last: latest }, function(response) {
        $(response.posts).appendTo($('.post-list'));
        returned = response.returned;
        latest = response.latest;

        // Remove the current inview element.  Add a new one.
        $('.inview').remove();
        if (response.die) {
          return false;
        }

        $('<div></div>').addClass('inview').appendTo($('.post-list'));

        $('img.lazy').lazyload();
        // Load Facebook
        load_facebook();
        set_votes();
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
    });
  }

  // Go.
  in_view();
});