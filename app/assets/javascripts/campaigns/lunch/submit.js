$(document).ready(function() {
  if ($('#new_post').length > 0) {
    var page = 1;
    $('#next-page').click(function() {
      page++;
      $('.page').hide();
      $('.page[data-page="' + page + '"]').show();
      return false;
    });
  }
});