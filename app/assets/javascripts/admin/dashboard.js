$(document).ready(function() {
  $('.popover-anchor').popover({
    placement: 'bottom',
    content: function() {
      return $(this).find(".popover-data-content").html();
    },
    trigger: 'hover',
    html: true
  });
  $(".sparkline_line_good span").sparkline("html", {
    type: "line",
    width: "200",
    height: "50"
  });  
  $(".percentage").map(function(){
    p = Math.round(parseFloat($(this).html()) - 100);
    color = p > 0 ? '#00c600' : '#c60000';
    plus = p > 0 ? '+' : '';
    $(this).css('color', color);
    $(this).html(plus + p + "%");
  });
  var graph = new Morris.Bar({
    element: 'eventsChart',
    data: $('#eventsChartData').data('json'),
    xkey: 'date',
    ykeys: ['view', 'click'],
    labels: ['Button views', 'Button clicks'],
    barColors: ['#989cf8', '#ccddff']
  });
} );

