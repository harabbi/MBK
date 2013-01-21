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
});

