// FORM PAGINATION 
//
// This file provides the functionality needed to scroll through multiple pages
// in a campaign.  For pagination to work, sections of the add / edit form should
// be surrounded by div's with the "page" class, and a "data-page" attribute.  Like
// so:
//  <div class="page" data-page="1">
//   <%= f.input :name %>
//  </div>
//  <div class="page" data-page="2">
//   <%= f.input :age %>
//  </div>
//
// The form must also include "next_page" and "prev_page" buttons as defined in
// the default form.

$(document).ready(function() {
  if (($('#new_post').length > 0 || $('[id^="edit_post"]').length > 0) && $('.page').length > 0) {
    var page = 1;
    var pages = [];
    $('.page').each(function() {
      pages.push($(this).data('page'));
    });

    $('#next-page').click(function() {
      page++;
      $('.page').hide();
      $('.page[data-page="' + page + '"]').show();
      if (page >= pages.length) {
        $('#next-page').hide();
      }
      if (page > 1) {
        $('#prev-page').show();
      }

      return false;
    });

    $('#prev-page').click(function() {
      page--;
      $('.page').hide();
      $('.page[data-page="' + page + '"]').show();
      if (page >= pages.length) {
        $('#next-page').hide();
      }
      if (page > 1) {
        $('#prev-page').show();
        if (page < pages.length) {
          $('#next-page').show();
        }
      }
      if (page == 1) {
        $('#prev-page').hide();
        $('#next-page').show();
      }

      return false;
    });
  }
});
