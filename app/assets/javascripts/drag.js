// syntactic sugar for finding empty DOM elements
// e.g.
// $('.klass:blank')
$.expr[':'].blank = function(obj){
  return obj.innerHTML.trim().length === 0;
};

// reset element position on window resize
$( window ).resize(function() {
  $('.drag').css("position", "static");
});

top_z_index = 0;
$(".drag")
.hammer({ drag_max_touches:0})
.on("drag", function(ev) {
  if (frozen == false) {
  // set a draggable element's position while being dragged
  var touches = ev.gesture.touches;
  var vertical = touches[0].pageY;
  var horizontal = touches[0].pageX;
  if ( vertical < $(window).scrollTop() ) {
    vertical = $(window).scrollTop();
  }
  if (horizontal < 0) {
    horizontal = 0;
  }
  if (horizontal > $(window).width() ) {
    horizontal = $(window).width();
  }
  if ( is_not_input ) {
    ev.gesture.preventDefault();
    target.css({
      left: horizontal-50,
      top: vertical-(50+$(window).scrollTop())
    });
  }
  ['.drop1','.drop2','.drop3'].forEach( function(i) {
    if ( vertical >= $(i).offset().top && vertical <= $(i).offset().top + $(i).height() && horizontal >= $(i).offset().left && horizontal <= $(i).offset().left + $(i).width() ) {
      $(i).addClass('hover');
    } else {
      $(i).removeClass('hover');
    }
  });
  // $('.blue-gradient').html( target.offset().top - $(window).scrollTop() );
  $('#drop-div h3').fadeOut('fast');
  $('#drop-div-toggle').show();
  }})
.on("touch", function(ev) {
  if (frozen == false) {
  // bring a draggable element to the front when clicked upon
  var touches = ev.gesture.touches;
  var vertical = touches[0].pageY;
  var horizontal = touches[0].pageX;
  target = $(touches[0].target).closest('.drag:not(.frozen)');
  is_not_input = !$(touches[0].target).is('input');
  if ( is_not_input ) {
    $('input').blur(); // remove focus from input element, when initiating drag
    ev.gesture.preventDefault();
    target.css({
      position: "fixed",
      left: horizontal-50,
      top: vertical-(50+$(window).scrollTop()),
      boxShadow: "5px 5px 10px #999"
    });
    if (target.hasClass('writable')) {
      var drop_zone = $('#drag-wrap-writein');
    } else {
      var drop_zone = $('.drag-wrap:blank:first');
    }
    former_parent = target.parent();
    if (former_parent.hasClass('drag-wrap')) {
      // do nothing
    } else {
      $(drop_zone).prepend( target );
    }
  }
  target.css('z-index', 999);
  }})
.on("release", function(ev) {
  if (frozen == false) {
  // set a draggable element's position upon release
  // ensure that the last-touched element has the highest z-index
  top_z_index = top_z_index + 1;
  if ( is_not_input ) {
      var touches = ev.gesture.touches;
      var vertical = parseInt(target.css('top'));
      var horizontal = touches[0].pageX;
    // set CSS according to whether the draggable element has been dropped in the target zone
    if ( vertical <= 355 ) {
      var z_base = 900;
      var position = 'fixed'
      var vertical_offset = 0;
    } else {
      var z_base = 100;
      var position = 'absolute'
      var vertical_offset = $(window).scrollTop();
    }
    ev.gesture.preventDefault();
    target.css({
      boxShadow: "none",
      top: vertical + vertical_offset,
      position: position
    });
    var in_target = false;
    ['.drop1','.drop2','.drop3'].forEach( function(i) {
      if
        (
          vertical + $(window).scrollTop() + 50 >= $(i).offset().top
          && vertical + $(window).scrollTop() + 50 <= $(i).offset().top + $(i).height()
          && horizontal >= $(i).offset().left
          && horizontal <= $(i).offset().left + $(i).width()
          )
      {
        in_target = true;
        var former_occupant = $(i).children('.drag').first();
        $(i).prepend( target ) ;

        // if a writable div is being dragged from the bottom and replacing a non-writable:
        if ( former_parent.attr('id') == 'drag-wrap-writein' && !former_occupant.hasClass('writable') ) {
          $('.drag-wrap:blank:first').prepend( former_occupant );
          console.log('test A');
        }

        // if a non-writable div is being dragged from the bottom and replacing a writable:
        else if ( !former_parent.hasClass('drop') && !target.hasClass('writable') && former_occupant.hasClass('writable') ) {
          $('#drag-wrap-writein').prepend( former_occupant );
          console.log( former_parent.attr('class') );
        }

        // otherwise, swap the target & former occupant:
        else {
          former_parent.prepend( former_occupant );
          console.log('test C');
        }

        former_occupant.removeClass('in-drop-zone');
        target.css('position','static');
      }
    });
    if ( vertical >= 66 && vertical <= 320) {
      target.addClass('in-drop-zone');
    } else {
      target.removeClass('in-drop-zone')
    }
    if ( $('.drop .drag').length == 0 ) {
      $('#drop-div h3').fadeIn('fast');
      $('#drop-div-toggle').hide();
    }
    if ( $('.drop .drag').length >= 1 ) {
      $('#red-ribbon h3').html('<a id="clickButton" href="#" onclick="selectPicks(); return false;">SAVE YOUR PICKS</a>');
      $('#red-ribbon h3').fadeIn();
    } else {
      $('#red-ribbon h3').fadeOut();
    }
  }
  target.css({
    zIndex: z_base + top_z_index, position: 'static'
  });
  $('.drop').removeClass('hover');
}});

function selectPicks() {
  $('#candidates').hide();
  $('#user-form').show();
  var first_choice = $('.drop1 .candidate').text();
  if (first_choice == '') {
    first_choice = $('.drop1 .write-in').val();
  }
  var second_choice = $('.drop2 .candidate').text();
  if (second_choice == '') {
    second_choice = $('.drop2 .write-in').val();
  }
  var third_choice = $('.drop3 .candidate').text();
  if (third_choice == '') {
    third_choice = $('.drop3 .write-in').val();
  }
  $('#vote_first_choice').val( first_choice );
  $('#vote_second_choice').val( second_choice );
  $('#vote_third_choice').val( third_choice );
  $('#red-ribbon h3').html('');
  $('#red-ribbon h3').css('opacity','0.0');
  frozen = true;
  document.body.scrollTop = document.documentElement.scrollTop = 0;
}

function saveWriteIn() {
  var write_in = $('.write-in').val();
  if ( $('.write-in').closest('.drop').hasClass('drop1') ) {
    $('#vote_first_choice').val( write_in );
  } else if ( $('.write-in').closest('.drop').hasClass('drop2') ) {
    $('#vote_second_choice').val( write_in );
  } else if ( $('.write-in').closest('.drop').hasClass('drop3') ) {
    $('#vote_third_choice').val( write_in );
  }
}

function cancelForm() {
  $('#candidates').show();
  $('#user-form').hide();
  $('#red-ribbon h3').html('<a id="clickButton" href="#" onclick="selectPicks(); return false;">SAVE &amp; SHARE YOUR PICKS</a>');
  $('#red-ribbon h3').css('opacity','1.0');
  $('#red-ribbon h3').show();
  frozen = false;
}

$(window).on('scroll resize', function() {
  var scroll_top = Math.min(111, $(window).scrollTop());
  $('.header').css('top', 0 - scroll_top + 'px');
  $('.header2').css('top', 110 - scroll_top + 'px');
  $('.header3').css('top', 111 - scroll_top + 'px');
  $('#drop-div').css('top', 126 - scroll_top + 'px');
  $('#red-ribbon').css('top', 280 - scroll_top + 'px');
});

$('.write-in').keyup(function() {
  $(this).prev(".write-name").html($(this).val());
});
