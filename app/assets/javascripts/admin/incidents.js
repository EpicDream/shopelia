$(document).ready(function() {
  incidentsTable = $('#incidents').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": false,
    "bFilter": true,
    "bPaginate": true,
    "sPaginationType": "bootstrap",
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#incidents').data('source'),
    "fnDrawCallback" : function() {
      $('.btn').on("click", function(event) {
        $(this).button('loading')
        var url = $(this).attr('data-update-url');
        $.ajax({
          url: url,
          type: "post",
          dataType: "script",
          data: {"_method":"put"}
        });
      });
      $('#incidents tbody tr').hover(
        function() {
          $(this).find("button").css("visibility", "visible");
        },
        function() {
          $(this).find("button").css("visibility", "hidden");
        } 
      );
    },
    "fnRowCallback": function(nRow, aData, iDisplayIndex) {
      nRow.className = "row-50";
      return nRow;
    }
  } );
} );

