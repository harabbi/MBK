// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
  $('.preview_search_table').dataTable();

  $('#search_search_id').live('change', function() {
    $.ajax({
      type: 'GET',
      url: '/',
      dataType: 'html',
      data: {
        search_id: $('#search_search_id').val()
      },
      success : function(data) {
        $('#search_form').html(data)
      }
    });
  });

  $('input').live('change', function() {
    $('#update_and_search').show();
  });

  $('#product_search_search_name').live('change', function() {
    $('#save_and_search').show();
  });

  $( "#dialog-form" ).dialog({
    autoOpen: false,
    height: 500,
    modal: true,
    position: { my: "center", at: "center", of: window },
    title: ""
  });
});

function start_spinner() {
  console.log('starting...');
  var opts = {
    lines: 12, // The number of lines to draw
    length: 135, // The length of each line
    width: 33, // The line thickness
    radius: 60, // The radius of the inner circle
    corners: 1, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    color: '#888', // #rgb or #rrggbb
    speed: 0.7, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: true, // Whether to render a shadow
    hwaccel: false, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: 'auto', // Top position relative to parent in px
    left: 'auto' // Left position relative to parent in px
  };
  var target = document.getElementById('search_form');
  var spinner = new Spinner(opts).spin(target);
}
