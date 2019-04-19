// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

showSmsIfCompletePhone = function(ev, duration) {
  duration = duration || 500;
  if ( $("#vote_phone").length > 0 && $("#vote_phone").val().replace(/[^0-9]/g,"").length >= 10 ) {
    if(duration == 500) { $("#idSmsOptIn").prop('checked', true); }
    $("#smsOptInBox").slideDown(duration);
  }
};

$("#vote_phone.watch").on('change keyup', showSmsIfCompletePhone);

$( document ).ready(function() {
  showSmsIfCompletePhone(null, 1);
});