$(document).ready(function() {
    $(".user-row").click(function() {
        $(".user-row").removeClass('user-row-select');
        $(this).toggleClass('user-row-select');
    });

  devicesTable = $('#devices').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": true,
    "bFilter": false,
    "bPaginate": true,
    "sPaginationType": "bootstrap",
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#devices').data('source'),
    "fnServerData": function ( sSource, aoData, fnCallback ) {
      aoData.push( { "name":"pending_answer", "value":$('#pendingAnswerFilter').val() } );
      $.getJSON( sSource, aoData, function (json) { 
        fnCallback(json)
      } );
    },
    "fnDrawCallback" : function() {
      $('.btn').on("click", function(event) {
        window.location = $(this).attr('data-url');
      });
      $('#devices tbody tr').hover(
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

  $("#pendingAnswerFilter").on('change', function() {
    devicesTable.fnReloadAjax();
  })
} );