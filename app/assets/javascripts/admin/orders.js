$(document).ready(function() {
  processingTable = $('#processingOrders').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": false,
    "bFilter": false,
    "bPaginate": false,
    "bInfo": false,
    "bSort": false,
    "sAjaxSource": $('#processingOrders').data('source')
  } );
  pendingTable = $('#pendingOrders').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "bLengthChange": false,
    "bFilter": false,
    "bPaginate": false,
    "bInfo": false,
    "bSort": false,
    "bAutoWidth": false,
    "sAjaxSource": $('#pendingOrders').data('source'),
    "fnDrawCallback" : function() {
      $('#pendingOrders .btn').on("click", function(event) {
        var url = $(this).attr('data-url');
        var state = $(this).attr('data-state');
        $('#confirmModelState').html(state);
        $('#confirmDestruction').off();
        $('#confirmDestruction').on("click", function(event){
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
              pendingTable.fnReloadAjax();
              $('#confirmModal').modal('hide');
            }
          });
        });
        $('#confirmModal').modal('show');
      });
      $('#pendingOrders tbody tr').hover(
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
  completedTable = $('#completedOrders').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "sPaginationType": "bootstrap",
    "bLengthChange": false,
    "bPaginate": true,
    "bFilter": false,
    "bInfo": false,
    "bSort": false,
    "sAjaxSource": $('#completedOrders').data('source')
  } );
  failedTable = $('#failedOrders').dataTable( {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "bServerSide": true,
    "sPaginationType": "bootstrap",
    "bLengthChange": false,
    "bPaginate": true,
    "bFilter": false,
    "bInfo": false,
    "bSort": false,
    "sAjaxSource": $('#failedOrders').data('source')
  } );
  Refresh.run();
} );

var Refresh = {
  totalPending: -1,
  totalProcessing: -1,
  totalFailed: -1,
  totalSuccess: -1,
  
	run: function() {
	  this.toggleVisibility();
		setInterval("Refresh.refresh()", 5000);
	},

	refresh: function() {
	  this.reloadAjax();
	  this.toggleVisibility();
    
    var totalProcessingNow = $("#processingOrders tr").size();
    if (totalProcessingNow > this.totalProcessing && this.totalProcessing > -1) {
      document.getElementById("sound-processing").play();
    }
    this.totalProcessing = totalProcessingNow;
    
    var totalFailedNow = $("#failedOrders tr").size();
    if (totalFailedNow > this.totalFailed && this.totalFailed > -1) {
      document.getElementById("sound-failed").play();
    }
    this.totalFailed = totalFailedNow;
    
    var totalPendingNow = $("#pendingOrders tr").size();
    if (totalPendingNow > this.totalPending && this.totalPending > -1) {
      document.getElementById("sound-pending").play();
    }
    this.totalPending = totalPendingNow;
    
    var totalSuccessNow = $("#completedOrders tr").size();
    if (totalSuccessNow > this.totalSuccess && this.totalSuccess > -1) {
      document.getElementById("sound-success").play();
    }
    this.totalSuccess = totalSuccessNow;
	},
	
	reloadAjax: function() {
    processingTable.fnReloadAjax();
    pendingTable.fnReloadAjax();
    completedTable.fnReloadAjax();
    failedTable.fnReloadAjax();
  },
  
  toggleVisibility: function() {
    if (processingTable.fnGetData().length > 0) {
      $('#processingOrdersSection').show('fast');
    } else {
      $('#processingOrdersSection').hide('fast');
    }
    
    if (pendingTable.fnGetData().length > 0) {
      $('#pendingOrdersSection').show('fast');
    } else {
      $('#pendingOrdersSection').hide('fast');
    }
  }  
}

