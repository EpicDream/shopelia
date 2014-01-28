var Index = {
  flinkersTable: null,

  init: function() {
    flinkersTable = $('#flinkers').dataTable( {
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "bServerSide": true,
      "bLengthChange": true,
      "bFilter": true,
      "bPaginate": true,
      "sPaginationType": "bootstrap",
      "bInfo": true,
      "bSort": false,
      "bAutoWidth": false,
      "sAjaxSource": $('#flinkers').data('source'),
      "fnDrawCallback" : function() {
        $('.btn').off("click");
        $('.btn').on("click", function(event) {
          var url = $(this).attr('data-destroy-url');
          $('#confirmModelUsername').html($(this).attr('data-username'));
          $('#confirmDestruction').on("click", function(event){
            $.ajax({
              url: url,
              type: "post",
              dataType: "json",
              data: {"_method":"delete"},
              error: function() {
                $('#confirmModal').modal('hide');
              },
              success: function(data) {
                flinkersTable.fnReloadAjax();
                $('#confirmModal').modal('hide');
              }
            });
          });
          $('#confirmModal').modal('show');
        });
        $('#flinkers tbody tr').hover(
          function() {
            $(this).find("button").css("visibility", "visible");
          },
          function() {
            $(this).find("button").css("visibility", "hidden");
          } 
        );
      },
      "fnServerData": function ( sSource, aoData, fnCallback ) {
        aoData.push( { "name":"publisher", "value":$('#publisherFilter').val() } );
        aoData.push( { "name":"staff_pick", "value":$('#staff-pick-filter').val() } );
        $.getJSON( sSource, aoData, function (json) { 
          fnCallback(json)
        } );
      }
    } );
    $(".filter-option").on('change', function() {
      flinkersTable.fnReloadAjax();
    });
  }
}

$(document).ready(function() {
  if ($('body.action-index').length > 0) {
    Index.init();
  }
});