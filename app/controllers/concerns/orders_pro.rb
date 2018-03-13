################################################################################
#   Orders processing module
#
#   19.02.2018  ZT
#   06.03.2018  New methods (order cancellation)
################################################################################

module OrdersPro
  extend ActiveSupport::Concern
  
  def cancel_order order

    response = ZtBtce.cancel_order order_id: order.ex_id
    
    if response['success'] == 0                       # Error
      order.status = 'rejected'
      order.error  = response['error']
      order.save
      flash[:danger] = "Order #{order.id}: #{order.error}"
    else                                              # Order has been canceled
      flash[:danger] = []
      order.status = 'canceled'
      order.error = nil
      order.save
    end
  end
  
  # Creates Fix Order for the *run* after the last executed *order*
  def create_fix_order run, order
      FixOrder.create run_id: run.id, price: order.price, amount: order.amount
    
    
  end
  
  # Creates all Orders for the Run
  def create_orders run
    orders = set_orders run
    for i in 0...run.orders_number
      Order.create run_id:    run.id,                      price: orders[i]['price'], 
                   amount:    orders[i]['amount'],    wavg_price: orders[i]['wavg_price'], 
                   fix_price: orders[i]['fix_price'], fix_amount: orders[i]['fix_amount']
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
      prices = set_logarithmic_prices run
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
      order['fix_amount'] = fix_amounts[i]
      orders[i] = order
    end
    
    orders
  end

  def set_kind kind
    kind == 'ask' ? -1 : 1
  end

  # TYhis is for testing only
  def set_logarithmic_prices run
#    prices = Array.new(run.orders_number)
    [1535.523, 1519.899, 1500.775, 1476.121, 1441.373, 1381.971]
  end

  def set_logarithmic_prices_new run
    prices             = []
    kind               = set_kind(run.kind)
    increments         = run.orders_number - 1
    prices[0]          = run.last     * (1.0 - kind * run.indent  / 100.0)
    prices[increments] = prices.first * (1.0 - kind * run.overlay / 100.0)
 
    if run.kind == 'bid'
      prices[0], prices[-1] = prices[-1], prices[0]   # swap first & last (must be increased order)
    end
   
    # values for calculation
    x1_min     = prices.first
    x1_max     = prices.last
    log_x1_min = Math.log10(x1_min)
    lod_diff   = Math.log10(x1_max / x1_min)
    
    x2_min     = 1
    x2_max     = 10
    x2_diff    = x2_max - x2_min
    fraction   = 0.4              # Empirical value
    x2         = x2_min           # initial value (for price.first)

    for i in 1...increments   # excluding first & last
      x2        = (x2_max - x2) * fraction + x2
      power     = log_x1_min + lod_diff / x2_diff * (x2 - x2_min)
      prices[i] = 10**power
    end
    
    if run.kind == 'bid'
      prices.reverse!
    end
    
    prices
  end
  
  def set_plain_prices run
    prices             = []
    kind               = set_kind(run.kind)
    increments         = run.orders_number - 1
    prices[0]          = run.last     * (1.0 - kind * run.indent  / 100.0)
    prices[increments] = prices.first * (1.0 - kind * run.overlay / 100.0)
    increment          = (prices.last - prices.first) / increments

    for i in (1..run.orders_number)
      prices[i] = prices[i-1] + increment
    end
    
    prices
  end
  
  # Preliminary - to be tested
  def trace_order order
    response = ZtBtce.order_info order_id: order.ex_id
    
    if response['success'] == 0                         # Error
      order.status = 'rejected'
      order.error  = response['error']
 
      flash[:danger] = "Order #{order.id}: #{order.error}"
    else                                                
      order.status = response['return']['status']
      order.error  = nil
      
      if order.ex_id == 0           # Order was fully 'matched'
        order.status = 'executed'
      elsif
        order.status = 'active'
      end
    end
    order.save
  end
end

