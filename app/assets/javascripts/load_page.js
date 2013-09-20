$(document).ready(function() {
  if (typeof campaign !== 'undefined') {
    $.post('/' + campaign.path + '/auth-bar', {}, function(response) {
      $('.utility-bar').html(response);
    });
  }
});
