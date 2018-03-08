/*******************************************************************************
 * Draws candlestcik charts for selected Time Frames with different Time Slots
 * 
 * 03.02.2018   ZT
 ******************************************************************************/
// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
  var i;
  var data    = [];
  var options = [];
  var len     = gon.candles.length;
  
  // Time slots         1     2      5    10    15    30  minutes
  // var chartWidth  = [ 7200, 7200, 6400, 6400, 1600, 1600];
  // var chartHeight = [  800,  800,  800,  800,  800,  800];

  if (gon.period <= 120.0) {          // <= 2 hours
    var chartWidth = 1200;
  } else if (gon.period <= 240.0) {   // <= 4 hours
    var chartWidth = 2400;
  } else if (gon.period <= 360.0) {   // <= 6 hours
    var chartWidth = 4800;
  } else {
    var chartWidth = 9600;
  };
  var chartHeight = 800;
  
  for (i = 0; i < len; i++) {
    data[i] = google.visualization.arrayToDataTable(
      gon.candles[i],
      true          // Treat first row as data as well
      );

    options[i] = {
      title:       'Time Slot: ' + (gon.time_slots[i] / 60).toString() + ' min',
      legend:      'none',
      width:       chartWidth[i],
      height:      chartHeight[i],
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
    var elementId = 'chart_div_' + i.toString();
    
    // Instantiate and draw each chart, passing in some its options
    var chart = new google.visualization.ComboChart(document.getElementById(elementId));
    chart.draw(data[i], options[i]);
  };
};
