/*******************************************************************************
 * Draws candlestcik charts for all Pairs aka WEX charts, using Google Charts
 * 
 * 28.12.2017   ZT
 ******************************************************************************/

// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
  var i;
  var data    = [];
  var options = [];
  var len     = gon.pairs.length;
  
  if (gon.time_slot == 60 || gon.time_slot == 120) {
    chartWidth  = 14400;
    chartHeight = 800;
  } else if (gon.time_slot == 300 || gon.time_slot == 600) {
    chartWidth  = 6400;
    chartHeight = 800;
  } else {
    chartWidth  = 1600;
    chartHeight = 800;
  };

  for (i = 0; i < len; i++) {
    data[i] = google.visualization.arrayToDataTable(
      gon.candles[i],
      true          // Treat first row as data as well
      );

    options[i] = {
      title:       gon.pairs[i],
      legend:      'none',
      width:       chartWidth,
      height:      chartHeight,
      seriesType:  "candlesticks",
      series: { 
        1: {type: "line", color: "cyan", lineWidth: 1},
        2: {type: "bars", color: "lightgrey", targetAxisIndex: 2}
      },
      bar:         { groupWidth: '61.8%' }, // 61.8% - golden ratio (default); 100% - removes space between bars.
      candlestick: {
        fallingColor: { strokeWidth: 0, fill: '#a52714' },  // red
        risingColor:  { strokeWidth: 0, fill: '#0f9d58' }   // green
      }
    };
  };

  for (i = 0; i < len; i++) {
    var elementId = gon.pairs[i] + '_chart_div';
    
    // Instantiate and draw each chart, passing in some its options
    var chart = new google.visualization.ComboChart(document.getElementById(elementId));
    chart.draw(data[i], options[i]);
  };
};
