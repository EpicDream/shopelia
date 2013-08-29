$(document).ready(function() {
  eventsTable = $('#events').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": true,
    "bFilter": false,
    "bPaginate": true,
    "bInfo": true,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#events').data('source'),
    "fnServerData": function ( sSource, aoData, fnCallback ) {
      aoData.push({ "name":"date_start", "value":$('#date-start').val() });
      aoData.push({ "name":"date_end", "value":$('#date-end').val() });
      aoData.push({ "name":"tracker", "value":$('#tracker').val() });
      aoData.push({ "name":"developer_id", "value":$('#developer').val() });
      $.getJSON( sSource, aoData, function (json) { 
        fnCallback(json)
      } );
    }
  } );

  var graph = new Morris.Line({
    element: 'eventsChart',
    data: [],
    xkey: 'date',
    ykeys: ['view','click'],
    labels: ['Button views', 'Button clicks']
  });

  function updateGraph() {
    $.ajax({
      url: '/admin/events.json',
      type: "get",
      dataType: "json",
      data: {
        "graph":"1",
        "date_start":$('#date-start').val(),
        "date_end":$('#date-end').val(),
        "developer_id":$('#developer').val(),
        "tracker":$('#tracker').val(),
      },
      success: function(data) {
        graph.setData(data);
      }
    });    
  }

  $('.filter-option').on('change', function(){
    updateGraph();
    eventsTable.fnReloadAjax();
  });

  updateGraph();
} );

