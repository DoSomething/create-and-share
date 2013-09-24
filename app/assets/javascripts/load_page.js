$(document).ready(function() {
  if (typeof campaign !== 'undefined') {
    $.post('/' + campaign.path + '/auth-bar.json', {}, function(response) {
      $('.utility-bar').html(response.response);
      user.id = response.uid;
      user.votes = response.votes;

      set_votes();
    });
  }
});
