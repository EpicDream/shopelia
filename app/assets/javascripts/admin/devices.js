var Show = {
  eventsTable: null,

  init: function() {
    eventsTable = $('#events').dataTable( {
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "bServerSide": true,
      "bLengthChange": true,
      "bFilter": false,
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
  if ($('body.action-show').length > 0) {
    Show.init();
  }
});
