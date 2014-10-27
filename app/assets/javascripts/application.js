// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require nestable
//= require jquery.nestable.js
//= require autocomplete-rails
//= require bootstrap-sprockets
//= require ckeditor/ckeditor
//= require autoSuggestBlur

$(document).ready(function () {
  $user_mentor = $('#user_mentor_name');
  $user_mentor_id = $('#user_mentor_id');
  checkAutoSuggest($user_mentor, $user_mentor_id);
});

