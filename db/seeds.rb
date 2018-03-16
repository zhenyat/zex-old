if Coin.count == 0
  Coin.create name: 'Bitcoin',          code: 'BTC'
  Coin.create name: 'Bitcoin Cash',     code: 'BCH'
  Coin.create name: 'Bitcoin Gold',     code: 'BCG'
  Coin.create name: 'Ethereum',         code: 'ETH'
  Coin.create name: 'Ethereum Classic', code: 'ETC'
  Coin.create name: 'Litecoin',         code: 'LTC'
 
  Coin.create name: 'US Dollar',        code: 'USD'
  Coin.create name: 'Euro',             code: 'EUR'
  Coin.create name: 'Russian Ruble',    code: 'RUR'
end

if Pair.count == 0
  info = ZtBtce.info
  
  if info.present?
    info['pairs'].each do |pair|
      pair_name = pair.first
      base      = pair_name.split('_').first.upcase
      quote     = pair_name.split('_').last.upcase
      code      = "#{base}/#{quote}"
      
      base_found   = Coin.find_by code: base 
      quote_found  = Coin.find_by code: quote
      
      if (base_found.present? && quote_found.present?)
        values    = pair.last

        Pair.create! base_id: base_found.id, quote_id: quote_found.id, name: pair_name, code: code,
                     decimal_places: values['decimal_places'],
                     max_price:  values['max_price'],  min_price: values['min_price'],
                     min_amount: values['min_amount'], hidden:    values['hidden'],
                     fee:        values['fee'],        status:    1
      end
    end
  end
end

if Run.count == 0
  Run.create pair_id: 1, kind: "ask", depo: 0.1e4, last: 0.17061367e4, indent: 5.0, overlay: 10.0, martingale: 15.0, orders_number: 6, profit: 2.0, scale: "logarithmic", stop_loss: 0.8616e4
end

if FixOrder.count == 0
  run    = Run.first
  o_type = (run.kind == 'ask') ? 'sell' : 'buy'
  f_type = (run.kind == 'ask') ? 'buy'  : 'sell'
  
  order = run.orders.first
  order.update x_id: 11223344, x_pair: order.run.pair.name, x_type: o_type, x_done_amount: order.amount, x_rest_amount: 0.0, x_rate: order.price, x_base: 0.0, x_quote: 0.0, x_timestamp: Time.now, status: 'executed', x_status: 'x_executed'
  FixOrder.create order_id: order.id, price: order.fix_price, amount: order.fix_amount, x_id: 11667788, x_type: f_type
end