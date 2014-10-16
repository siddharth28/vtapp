
function checkAutoSuggest(autoSuggestField, autoSuggestHiddenField) {
  autoSuggestField.blur(function(){
    if (autoSuggestHiddenField.val() == '') {
      $(this).val('');
    };
  });
}