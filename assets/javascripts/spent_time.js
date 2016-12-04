$(document).on('change', '.select-all-checkbox', function(e) {
  check_all_relevant_checkboxes($(e.target))
});

var check_all_relevant_checkboxes = function(control) {
  var checked = control.is(':checked');
  var index = control.closest('th').index();

  $(control).closest('table').find('tbody > tr').each(function() {
    $(this).toggleClass('active').find('td:nth-child(' + (index + 1) + ') input[type=checkbox]').prop('checked', checked);
  });
}
