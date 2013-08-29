$(document).ready(function() {
  vikingsTable = $('#vikings').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": true,
    "bFilter": true,
    "bPaginate": true,
    "sPaginationType": "bootstrap",
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#vikings').data('source'),
    "fnDrawCallback" : function() {
      $('.btn.btn-success').on("click", function(event) {
        $(this).button('loading')
        var url = $(this).attr('data-retry-url');
        $.ajax({
          url: url,
          type: "get",
          dataType: "script"
        });
      });
      $('.btn.btn-warning').on("click", function(event) {
        $(this).button('loading')
        var url = $(this).attr('data-mute-url');
        $.ajax({
          url: url,
          type: "get",
          data: {"delay":0},
          dataType: "script"
        });
      });
      $('.btn.btn-danger').on("click", function(event) {
        $(this).button('loading')
        var url = $(this).attr('data-mute-url');
        $.ajax({
          url: url,
          type: "get",
          data: {"delay":1},
          dataType: "script"
        });
      });
      $('#vikings tbody tr').hover(
        function() {
          $(this).find("button").css("visibility", "visible");
        },
        function() {
          $(this).find("button").css("visibility", "hidden");
        } 
      );

    },
  } );

  $('.successKnob').knob({
    'width': 370,
    'height': 300,
    'fgColor': "#66cc66",
    'bgColor': "#cc6666",
    'inputColor': "#666666",
    'angleOffset': -125,
    'angleArc': 250,
    'readOnly': true    
  });

  $('.merchantKnob').knob({
    'width': 150,
    'height': 120,
    'fgColor': "#66cc66",
    'bgColor': "#cc6666",
    'inputColor': "#666666",
    'angleOffset': -125,
    'angleArc': 250,
    'readOnly': true    
  });  

} );

