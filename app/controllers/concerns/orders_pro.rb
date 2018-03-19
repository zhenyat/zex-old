################################################################################
#   Orders processing module
#
#   19.02.2018  ZT
#   06.03.2018  New methods (order cancellation)
################################################################################
module OrdersPro
  extend ActiveSupport::Concern
  
  ##############################################################################
  # Cancel the *order*
  ##############################################################################
  def cancel_order order
    response  = ZtBtce.cancel_order order_id: order.x_id
  
    error_msg = handle_response order, response
    
    flash[:danger] = error_msg if error_msg.present? 
    
    if flash[:danger].empty?
      run.status = 'active'
      run.save!
      
      flash.discard
      flash[:success] = "Well done! Orders have been placed"
    end
  end
  
  ##############################################################################
  # Checks *fix_order*
  # 
  # # NB! Trade API method 'Trade' accepts *THREE* decimal digits for *price* only: round(3) to be applied!
  ##############################################################################
  def check_fix_order order
    puts "ZT! #{order.x_id}"
    response = ZtBtce.order_info order.x_id

    if response['success'] == 0                             # Error
      order.status = 'rejected'
      order.error  = response['error']
    else
      order.x_timestamp = response['return']['timestamp_created'] if order.x_timestamp.nil?

      # Just some verifications
      if order.amount == response['return']['start_amount'] && order.price == response['return']['rate'] 
        order.x_rest_amount = response['return']['amount']
        order.x_done_amount = response['return']['start_amount'] - order.x_rest_amount
        order.status        = response['return']['status']
        order.error         = nil
      else                                                  # Something went wrong
        order.status = 'wrong'
        order.error  = "Something went wrong: price = #{order['return']['rate']}; amount = #{['return']['start_amount']}"
      end 
    end
    
    order.save!

    if order.error.present?
      "Order #{order.id}: #{order.error}"   # Return error message
    else
      nil
    end
  end
  
  ##############################################################################
  # Checks *order*
  # 
  # # NB! Trade API method 'Trade' accepts *THREE* decimal digits for *price* only: round(3) to be applied!
  ##############################################################################
  def check_order order
    response = ZtBtce.order_info order.x_id

    if response['success'] == 0                             # Error
      order.status = 'rejected'
      order.error  = response['error']
    else
      order.x_timestamp = response['return']['timestamp_created'] if order.x_timestamp.nil?

      # Just some verifications
      if order.amount == response['return']['start_amount'] && order.price == response['return']['rate'] 
        order.x_rest_amount = response['return']['amount']
        order.x_done_amount = response['return']['start_amount'] - order.x_rest_amount
        order.status        = response['return']['status']
        order.error         = nil
      else                                                  # Something went wrong
        order.status = 'wrong'
        order.error  = "Something went wrong: price = #{order['return']['rate']}; amount = #{['return']['start_amount']}"
      end 
    end
    
    order.save!

    if order.error.present?
      "Order #{order.id}: #{order.error}"   # Return error message
    else
      nil
    end
  end
  
  ##############################################################################
  # Creates Fix Order for the Run after the last executed *order*
  ##############################################################################
  def create_fix_order order
      FixOrder.create run_id: order.run.id, price: order.fix_price, amount: order.fix_amount 
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

  ##############################################################################
  # Places *order* (fix = false) or *fix_order* (fix = true)
  # 
  # # NB! Trade API method 'Trade' accepts *THREE* decimal digits for *price* only: round(3) to be applied!
  ##############################################################################
  def place_order order, fix = false

    if fix
      run  = order.order.run                        #  FixOrder.Order.Run
      type = (run.kind == 'ask') ? 'buy' : 'sell'   # opposite to Run's kind
    else
      run  = order.run                              # Order.Run
      type = (run.kind == 'ask') ? 'sell' : 'buy'
    end
    pair = run.pair.name

    response = ZtBtce.trade pair: pair, type: type, rate: order.price.round(3), amount: order.amount

    if response['success'] == 0                             # Error
      order.status = 'rejected'
      order.error  = response['error']
    else                                                    # Order has been placed
      order.x_id          = response['return']['order_id']
      order.x_done_amount = response['return']['received']
      order.x_rest_amount = response['return']['remains']

      pair_name     = order.run.pair.name
      order.x_base  = response['return']['funds'][pair_name.split('_').first]
      order.x_quote = response['return']['funds'][pair_name.split('_').first]

      # Order was fully 'matched' if its id = 0
      order.status = (order.x_id == 0) ? 'executed' : 'active'

      order.error  = nil
    end

    order.save!
    "Order #{order.id}: #{order.error}" if order.error.present?   # Return error message 
  end
    
  ##############################################################################
  # Handles API *response* and updates DB *order* record properly
  ##############################################################################
#  def handle_response order, response
#    if response['success'] == 0                       # Error
#      order.status = 'rejected'
#      order.error  = response['error']
#      order.save
#      
#      "Order #{order.id}: #{order.error}"             # Return error message
#      
#    else                                              # Order has been handled
#      order.x_id          = response['return']['order_id']
#      order.x_done_amount = response['return']['received']
#      order.x_rest_amount = response['return']['remains']
#      
#      order.run.pair
#      order.x_base  = response['return']['funds'][]
#      order.x_quote = response['return']['order_id']
#      
#      # Order was fully 'matched' if its id = 0
#      order.status = (order.x_id == 0) ? 'executed' : 'active'
#
#      order.error  = nil
#      order.save
#      
#      nil                                             # No error message returned
#    end
#  end
  
  ##############################################################################
  #  Calculates parameters of the *run* orders
  ##############################################################################
  def set_orders run
    #####   Coefficients    #####
    kind      = set_kind(run.kind)                              # Sign for factors calculation
    m_factor  = 1.0 + kind * run.martingale / 100.0             # Martingale factor
    pf        = (run.profit + 2.0 * run.pair.fee) / run.orders_number  # (Profit + 2*Fee) / orders (%)
    pf_factor = 1.0 + kind * pf / 100.0                         # profit & Fee factor for ONE order
    factor    = 0    

    # Initialize Arrays
    orders        = Array.new(run.orders_number)    # Array of orders hashes 
    prices        = Array.new(run.orders_number)    # Array of orders prices
    base_amounts  = Array.new(run.orders_number)    # Array of orders amounts in base  currency (e.g. BTC)
    quote_amounts = Array.new(run.orders_number)    # Array of orders amounts in quote currency (e.g. USD)
    fix_amounts   = Array.new(run.orders_number)    # Array of orders Fix amounts
    fix_prices    = Array.new(run.orders_number)    # Array of orders Fix prices
    wavg_amounts  = Array.new(run.orders_number) {Array.new(run.orders_number, 0)}  # Matrix of Weighted Average Amounts 
    wavg_prices   = Array.new(run.orders_number, 0) # Array of orders Weighted Average prices
    
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

  ##############################################################################
  #  Sets *kind* value for orders calculation
  ##############################################################################
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
    response = ZtBtce.order_info order_id: order.x_id
    
    if response['success'] == 0                         # Error
      order.status = 'rejected'
      order.error  = response['error']
 
      flash[:danger] = "Order #{order.id}: #{order.error}"
    else                                                
      order.status = response['return']['status']
      order.error  = nil
      
      if order.x_id == 0           # Order was fully 'matched'
        order.status = 'executed'
      elsif
        order.status = 'active'
      end
    end
    order.save
  end
end

