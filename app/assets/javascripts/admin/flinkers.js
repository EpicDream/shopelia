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
      "fnServerData": function ( sSource, aoData, fnCallback ) {
        aoData.push( { "name":"publisher", "value":$('#publisherFilter').val() } );
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