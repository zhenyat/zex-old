################################################################################
#   Orders processing module
#
#   19.02.2018  ZT
################################################################################

module OrdersPro
  extend ActiveSupport::Concern
  
  def create_orders run
    orders = set_orders run
    for i in 0...run.orders_number
      Order.create run_id:    run.id,               price:      orders[i]['price'], 
                   amount:    orders[i]['amount'],  wavg_price: orders[i]['wavg_price'], 
                   fix_price: orders[i]['fix_price']
    end
  end
  
  def set_orders run
    #####   Coefficients    #####
    kind      = set_kind(run.kind)                              # Sign for factors calculation
    m_factor  = 1.0 + kind * run.martingale / 100.0             # Martingale factor
    pf        = (run.profit + 2.0 * run.pair.fee) / run.orders_number  # (Profit + 2*Fee) / orders (%)
    pf_factor = 1.0 + kind * pf / 100.0                         # profit & Fee factor for ONE order
    factor    = 0    

    # Initialize Arrays
    orders        = Array.new(run.orders_number)   # Array of orders hashes 
    prices        = Array.new(run.orders_number)   # Array of orders prices
    base_amounts  = Array.new(run.orders_number)   # Array of orders amounts in base  currency (e.g. BTC)
    quote_amounts = Array.new(run.orders_number)   # Array of orders amounts in quote currency (e.g. USD)
    fix_amounts   = Array.new(run.orders_number)   # Array of orders Fix amounts
    fix_prices    = Array.new(run.orders_number)   # Array of orders Fix prices
    wavg_amounts  = Array.new(run.orders_number) {Array.new(run.orders_number, 0)}  # Matrix of Weighted Average Amounts 
    wavg_prices   = Array.new(run.orders_number, 0) # # Array of orders Weighted Average prices
    
    #####   Calculate order prices   #####
    if run.scale == 'linear'
      prices = set_plain_prices run
    else
      prices = set_logarithmic_prices #run
    end

    #####   Calculate order amounts   #####
    for i in 0...run.orders_number
      factor += m_factor**i
    end

    quote_amounts[0] = run.depo / factor            # order increment
    base_amounts[0]  = quote_amounts[0] / prices[0]
    fix_amounts[0]   = base_amounts[0]
      
    for i in 1...run.orders_number
      quote_amounts[i] = quote_amounts[i-1] * m_factor
      base_amounts[i]  = quote_amounts[i] / prices[i]
      fix_amounts[i]   = fix_amounts[i-1] + base_amounts[i]
    end

    #####   Calculate Matrix of Weighted Average Amounts and output data  #####
    for i in 0...run.orders_number
      for j in 0..i
        wavg_amounts[i][j] = base_amounts[j] / fix_amounts[i] # Matrix
        wavg_prices[i]    += prices[j] * wavg_amounts[i][j]   # Weighted Average Prices (w/o profit & fee)
      end
      fix_prices[i] = wavg_prices[i] * pf_factor              # Fix Prices (with profit & fee)
    end
    
    #####   Orders    #####
    for i in 0...run.orders_number
      order = {}
      order['price']      = prices[i]
      order['amount']     = base_amounts[i]
      order['wavg_price'] = wavg_prices[i]
      order['fix_price']  = fix_prices[i]
      orders[i] = order
    end
    
    orders
  end

  def set_kind kind
    kind == 'ask' ? 1 : -1
  end

  # TBD
  def set_logarithmic_prices #run
#    prices = Array.new(run.orders_number)
    [1535.523, 1519.899, 1500.775, 1476.121, 1441.373, 1381.971]
  end

  def set_plain_prices run
    prices             = []
    kind               = set_kind(run.kind)
    increments         = run.orders_number - 1
    prices[0]          = run.last     * (1.0 + kind * run.indent  / 100.0)
    prices[increments] = prices.first * (1.0 + kind * run.overlay / 100.0)
    increment          = (prices.last - prices.first) / increments

    for i in (1..run.orders_number)
      prices[i] = prices[i-1] + increment
    end
    
    prices
  end
end

