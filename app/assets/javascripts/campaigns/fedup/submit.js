$(document).ready(function() {
  $('#post_school_id').autocomplete({
    source: function(request, response) {
      $.ajax({
        url: "/" + campaign.path + "/posts/school_lookup.json",
        dataType: 'json',
        type: 'GET',
        data: {
          term: request.term,
          state: $('#post_state').val(),
        },
        success: function(data) {
          response(data);
        }
      });
    },
    change: function(event, ui) {
      $('.ui-autocomplete-input').addClass('throbbing');
    },
    close: function() {
    },
    minLength: 2,
    select: function( event, ui ) {
      $('.first-value').show();
      $('.ui-autocomplete-input').removeClass('throbbing');
      $('.first-value').addClass('primary').removeClass('secondary').removeAttr('disabled');
    }
  });

  if ($('#post_state').val() == "") {
    $('.post_school_id').hide();

    $('#post_state').change(function() {
      if ($(this).val() != "") {
        $('.post_school_id').slideDown('fast');
      }
      else {
        $('.post_school_id').slideUp('fast');
      }
    });
  }
});
