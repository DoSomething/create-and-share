// FILTERS
// -------
$(function() {
  // Get user filter input and set destination
  $('#submit_filter').click(function(){
    var $type = $('#animal_filter').val();
    var $state = $('#state_filter').val();
    var $this = $(this);

    // The destination parameter is unbiased.  We need to tell it where to go here.
    var dest;
    if ($type == 'featured') {
      dest = 'featured';
    }
    else {
      dest = ($type !== 'all') ? $type + (($state !== '') ? '-' + $state : '') : (($state !== '') ? $state : '');
    }

    document.location.href = (dest !== '' ? '/' + dest : '/');
    return false;
  });
});
