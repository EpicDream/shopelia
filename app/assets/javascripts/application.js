// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap

$(document).ready(function() {
  $(".modal-button").on('click', function(event) {
    event.preventDefault();
    id = $(this).attr('target-modal');
    $('#' + id).find('.modal-content').load($(this).attr('target-url'));
    $('#' + id).modal('show').on('shown', function() {
      $(ClientSideValidations.selectors.forms).validate();
      $(this).unbind('shown');
    });
  });
  $(".fade-area").hover(
    function() {
      $(this).find("a").each(function() {
        $(this).fadeIn(100);
      })
    },
    function() {
      $(this).find("a").each(function() {
        $(this).fadeOut(100);
      })
    } 
  );
  showSpinners();
  //monitorCartItems();
});
