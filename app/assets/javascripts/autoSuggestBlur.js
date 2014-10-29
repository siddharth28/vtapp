function checkAutoSuggest(autoSuggestField, autoSuggestHiddenField) {
  autoSuggestField.blur(function(){
    if (autoSuggestHiddenField.val() == '') {
      $(this).val('');
    };
  });
}


$(document).ready(function () {
  checkAutoSuggest($('#user_mentor_name'), $('#user_mentor_id'));
  checkAutoSuggest($('#task_parent_title'), $('#task_parent_id'));
  checkAutoSuggest($('#task_reviewer_name'), $('#task_reviewer_id'))
});