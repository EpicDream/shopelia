$(document).ready(function() {
  ordersTable = $('#orders').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": true,
    "bFilter": false,
    "bPaginate": true,
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#orders').data('source'),
    "fnServerData": function ( sSource, aoData, fnCallback ) {
      aoData.push( { "name":"state", "value":$('#stateFilter').val() } );
      $.getJSON( sSource, aoData, function (json) { 
        fnCallback(json)
      } );
    },    
    "fnDrawCallback" : function() {
      $('#orders .btn').on("click", function(event) {
        var url = $(this).attr('data-url');
        var state = $(this).attr('data-state');
        $('#confirmModelState').html(state);
        $('#confirmModalAction').off();
        $('#confirmModalAction').on("click", function(event){
          $.ajax({
            url: url,
            dataType: "json",
            type : "put",
            contentType: "application/json",
            data: JSON.stringify({ "state": state }),
            error: function() {
              $('#confirmModal').modal('hide');
            },
            success: function(data) {
              ordersTable.fnReloadAjax();
              $('#confirmModal').modal('hide');
            }
          });
        });
        $('#confirmModal').modal('show');
      });
      $('#orders tbody tr').hover(
        function() {
          $(this).find("button").each(function() {
            $(this).css("visibility", "visible");
          })
        },
        function() {
          $(this).find("button").each(function() {
            $(this).css("visibility", "hidden");
          })
        } 
      );
    },
    "fnRowCallback": function(nRow, aData, iDisplayIndex) {
      nRow.className = "row-50";
      return nRow;
    }  
  } );
  $(".filter-option").on('change', function() {
    ordersTable.fnReloadAjax();
  })
} );
