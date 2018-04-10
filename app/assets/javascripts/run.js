/*
 * Prints an Object recursively
 * 
 * @param {type} printthis
 * @param {type} returnoutput
 * @return {String}
 */ 
function print_r(printthis, returnoutput) {
    var output = '';

    if($.isArray(printthis) || typeof(printthis) === 'object') {
        for(var i in printthis) {
            output += i + ' : ' + print_r(printthis[i], true) + '\n';
        }
    }else {
        output += printthis;
    }
    if(returnoutput && returnoutput === true) {
        return output;
    }else {
        alert(output);
    }
}
/*
 * Changes input values: Last Price and Stop Loss
 */
function changeFieldsValues() {

  var pairId = parseInt((document.getElementById('run_pair_id').value));
  var pair   = gon.pair_names[pairId];

//  print_r(gon.objects);

  gon.objects.forEach(function(el) {
    if (el['pair'] === pair) {
      document.getElementById('run_last').value = el['last'];
    }
  });
  
  changeStopLoss();
}

/*
 * Changes input values: Stop Loss
 */
function changeStopLoss() {
  var runKind = document.getElementById('run_kind').value;
  var overlap = document.getElementById('run_overlap').value;
  var last    = document.getElementById('run_last').value;

  if (runKind === 'sell') {
    var stopLoss = last * (1. - overlap * 2 / 100.0);
  } else {
    var stopLoss = last * (1. + overlap * 2 / 100.0) ;
  }
  document.getElementById('run_stop_loss').value = stopLoss;
}