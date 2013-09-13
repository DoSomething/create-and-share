$(document).ready(function() {
  var page = 0;     // Default page
  var running = 10; // How many posts are currently shown
  var done = [];
  var loaded = [];

  function in_view() {
    function load_the_scroll(elm, response) {
      // Unbind the last, last post's ID so we don't load again and again.
      elm.unbind('inview');

      if (count <= 10) {
        $('.inview').remove();
        return false;
      }

      $(response.posts).appendTo($('.post-list'));
      $('img.lazy').lazyload();

      // Remove the current inview element.  Add a new one.
      $('.inview').remove();
      if (response.die) {
        return false;
      }

      $('<div></div>').addClass('inview').appendTo($('.post-list'));

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
    }
    // Start the scroll load on the last post.  Leaves the perception of a faster infinite scroll.
    $('.id-' + latest).bind('inview', function(event, visible) {
      // Page + 1
      page++;
      var $elm = $(this);

      // Load the next scroll
      $.post('/' + campaign.path + '/posts/scroll.json', { filter: filter, type: campaign.scroll_type, page: page, last: latest }, function(response) {
        returned = response.returned;
        latest = response.latest;

        load_the_scroll($elm, response);
      });
    });
  }

  // Go.
  in_view();
});