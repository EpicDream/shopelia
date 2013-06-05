$.fn.dataTableExt.oApi.fnReloadAjax = function ( oSettings, sNewSource, fnCallback, bStandingRedraw )
{
    if ( sNewSource !== undefined && sNewSource !== null ) {
        oSettings.sAjaxSource = sNewSource;
    }
 
    // Server-side processing should just call fnDraw
    if ( oSettings.oFeatures.bServerSide ) {
        this.fnDraw();
        return;
    }
 
    this.oApi._fnProcessingDisplay( oSettings, true );
    var that = this;
    var iStart = oSettings._iDisplayStart;
    var aData = [];
 
    this.oApi._fnServerParams( oSettings, aData );
 
    oSettings.fnServerData.call( oSettings.oInstance, oSettings.sAjaxSource, aData, function(json) {
        /* Clear the old information from the table */
        that.oApi._fnClearTable( oSettings );
 
        /* Got the data - add it to the table */
        var aData =  (oSettings.sAjaxDataProp !== "") ?
            that.oApi._fnGetObjectDataFn( oSettings.sAjaxDataProp )( json ) : json;
 
        for ( var i=0 ; i<aData.length ; i++ )
        {
            that.oApi._fnAddData( oSettings, aData[i] );
        }
         
        oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
 
        that.fnDraw();
 
        if ( bStandingRedraw === true )
        {
            oSettings._iDisplayStart = iStart;
            that.oApi._fnCalculateEnd( oSettings );
            that.fnDraw( false );
        }
 
        that.oApi._fnProcessingDisplay( oSettings, false );
 
        /* Callback user function - for event handlers etc */
        if ( typeof fnCallback == 'function' && fnCallback !== null )
        {
            fnCallback( oSettings );
        }
    }, oSettings );
};

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
    "sAjaxSource": $('#pendingOrders').data('source')
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
  total: 0,
  
	run: function() {
	  Refresh.refresh();
		setInterval("Refresh.refresh()", 5000);
	},

	refresh: function() {
    processingTable.fnReloadAjax();
    pendingTable.fnReloadAjax();
    completedTable.fnReloadAjax();
    failedTable.fnReloadAjax();
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
    var total = $("#processingOrdersSection tr").size();
    if (this.total > total) {
      document.getElementById("sound-bell").play();
    }
	}
}

