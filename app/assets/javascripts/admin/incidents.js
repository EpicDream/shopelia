$(document).ready(function() {
  incidentsTable = $('#incidents').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": true,
    "bFilter": true,
    "bPaginate": true,
    "sPaginationType": "bootstrap",
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#incidents').data('source'),
    "fnServerData": function ( sSource, aoData, fnCallback ) {
      aoData.push( { "name":"severity", "value":$('#severityFilter').val() } );
      $.getJSON( sSource, aoData, function (json) { 
        fnCallback(json)
      } );
    },
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

  $("#severityFilter").on('change', function() {
    incidentsTable.fnReloadAjax();
  })
} );

