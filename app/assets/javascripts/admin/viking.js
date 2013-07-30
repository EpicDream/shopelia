$(document).ready(function() {
  vikingsTable = $('#vikings').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": false,
    "bFilter": true,
    "bPaginate": true,
    "sPaginationType": "bootstrap",
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#vikings').data('source'),
    "fnDrawCallback" : function() {
      $('.btn').on("click", function(event) {
        $(this).button('loading')
        var url = $(this).attr('data-retry-url');
        $.ajax({
          url: url,
          type: "get",
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
} );

