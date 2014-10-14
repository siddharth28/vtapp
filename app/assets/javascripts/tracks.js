$(document).ready(function(){
  $('#track_owner_name').bind('railsAutocomplete.select', function(event, data){
    var $this = $(this);
    $('#track_owner_email').val($this.val().split(':')[1]);
    $this.val($this.val().split(':')[0]);
  });
});