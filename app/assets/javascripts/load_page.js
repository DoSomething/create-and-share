function admin_tools() {
  $.post('/' + campaign.path + '/is-admin.json', {}, function(response) {
    if (response.is_admin === true) {
      $('.flag-container').html(response.tools);
      $('.flag-container').each(function() {
        var $ids = $(this);
        $ids.html($ids.html().replace(/ID/g, $ids.parent().data('id')));
      });
    }
  });
}

$(document).ready(function() {
  if (typeof campaign !== 'undefined') {
    $.post('/' + campaign.path + '/auth-bar.json', {}, function(response) {
      $('.utility-bar').html(response.response);
      user.id = response.uid;
      user.votes = response.votes;

      set_votes();
      admin_tools();
    });
  }
});
