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

    var first_position = '0 0';
    var second_position = '0 -39px';
    var third_position = '0 -78px';

    $('#edit-final-submit').hide();
    $('#next-page').attr('value', 'tell us more about your lunch').addClass('first-value');

    $('#next-page').click(function() {
      page++;
      $('.page').hide();
      $('.page[data-page="' + page + '"]').show();
      if (page >= pages.length) {
        $('#next-page').hide();
        $('#edit-final-submit').show();
      }
      if (page > 1) {
        $('#next-page').attr('value', 'next page').removeClass('first-value');
        $('#prev-page').show();
        $('#counter').css('background-position', second_position);
      }
      if (page == 3) {
        $('#counter').css('background-position', third_position);
      }

      return false;
    });

    $('#prev-page').click(function() {
      page--;
      $('.page').hide();
      $('.page[data-page="' + page + '"]').show();
      if (page >= pages.length) {
        $('#next-page').hide();
        $('#edit-final-submit').hide();
      }
      if (page > 1) {
        $('#prev-page').show();
        if (page < pages.length) {
          $('#next-page').show().removeClass('first-value');
        }
      }
      if (page == 1) {
        $('#prev-page').hide();
        $('#next-page').show().attr('value', 'tell us more about your lunch').addClass('first-value')
        $('#counter').css('background-position', first_position);
      }
      if (page == 2) {
        $('#edit-final-submit').hide();
        $('#counter').css('background-position', second_position);
      }

      return false;
    });
  }
});
