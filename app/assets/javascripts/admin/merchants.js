var Index = {
  merchantsTable: null,

  init: function() {
    merchantsTable = $('#merchants').dataTable( {
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "bServerSide": true,
      "bLengthChange": true,
      "bFilter": true,
      "bPaginate": true,
      "sPaginationType": "bootstrap",
      "bInfo": true,
      "bSort": false,
      "bAutoWidth": false,
      "sAjaxSource": $('#merchants').data('source'),
      "fnServerData": function ( sSource, aoData, fnCallback ) {
        aoData.push( { "name":"vulcain", "value":$('#vulcainFilter').val() } );
        $.getJSON( sSource, aoData, function (json) { 
          fnCallback(json)
        } );
      }
    } );
    $(".filter-option").on('change', function() {
      merchantsTable.fnReloadAjax();
    });
  }
}

var Show = {
  ordersTable: null,
  eventsTable: null,

  init: function() {
    ordersTable = $('#orders').dataTable( {
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "bServerSide": false,
      "bLengthChange": true,
      "bFilter": true,
      "bPaginate": true,
      "sPaginationType": "bootstrap",
      "bInfo": true,
      "bSort": true,
      "bAutoWidth": false,
    } );
    eventsTable = $('#events').dataTable( {
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "bServerSide": true,
      "bLengthChange": true,
      "bFilter": true,
      "bPaginate": true,
      "sPaginationType": "bootstrap",
      "bInfo": true,
      "bSort": false,
      "bAutoWidth": false,
      "sAjaxSource": $('#events').data('source')
    } );    
  }
}

$(document).ready(function() {
  if ($('body.action-index').length > 0) {
    Index.init();
  } else if ($('body.action-show').length > 0) {
    Show.init();
  }
});