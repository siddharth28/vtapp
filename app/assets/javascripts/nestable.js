$(document).ready(function() {
  $('#nestable-menu').on('click', function(e) {
    var target = $(e.target),
      action = target.data('action');
    if(action === 'expand-all') {
      $('.dd').nestable('expandAll');
    }
    if(action === 'collapse-all') {
      $('.dd').nestable('collapseAll');
    }
  });
  $('#nestable3').nestable({
    callback: function(l, e) {
    }
  });
});