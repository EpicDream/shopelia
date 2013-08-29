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
      "sAjaxSource": $('#merchants').data('source')
    } );
  }
}

$(document).ready(function() {
  if ($('body.action-index').length > 0) {
    Index.init();
  } 
});
