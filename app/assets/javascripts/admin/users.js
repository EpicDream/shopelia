var Index = {
  usersTable: null,
  usersGraph: null,

  init: function() {
    usersTable = $('#users').dataTable( {
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "bServerSide": true,
      "bLengthChange": true,
      "bFilter": true,
      "bPaginate": true,
      "sPaginationType": "bootstrap",
      "bInfo": true,
      "bSort": false,
      "bAutoWidth": false,
      "sAjaxSource": $('#users').data('source'),
      "fnDrawCallback" : function() {
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
                usersTable.fnReloadAjax();
                $('#confirmModal').modal('hide');
              }
            });
          });
          $('#confirmModal').modal('show');
        });
        $('#users tbody tr').hover(
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
    usersGraph = new Morris.Line({
      element: 'signUpChart',
      data: [],
      xkey: 'date',
      ykeys: ['value'],
      labels: ['Registrations']
    });
    Index.updateGraph();
    $('.graph-option').on('change', function(){
      Index.updateGraph();
    });
  },

  updateGraph: function() {
    $.ajax({
      url: '/admin/users.json',
      type: "get",
      dataType: "json",
      data: {
        "graph":"1",
        "date_start":$('#date-start').val(),
        "date_end":$('#date-end').val(),
        "visitor":$('#visitor').val()
      },
      success: function(data) {
        usersGraph.setData(data);
      }
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
  if ($('body.action-index').length > 0) {
    Index.init();
  } else if ($('body.action-show').length > 0) {
    Show.init();
  }
});
