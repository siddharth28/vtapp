$(document).ready(function(){
  $('#track_owner').bind('railsAutocomplete.select', function(event, data){
    var $this = $(this);
    $this.val($this.val().split(':')[1])
  });
});