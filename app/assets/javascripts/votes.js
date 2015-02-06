// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( document ).ready(function() {
  $('select').change(function() {
    var target = this.id.replace('target','#vote');
    $(target).val(this.value);
  });

  $('.social').click(function(){
    var width = window.innerWidth;
    var left = (width - 626)/2;
    return !window.open(this.href, '_blank', 'height=436, width=626, top=100, left=' + left);
  });
});