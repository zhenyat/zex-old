################################################################################
#   Orders processing module
#
#   19.02.2018  ZT
#   06.03.2018  New methods (order cancellation)
################################################################################
module OrdersPro
  extend ActiveSupport::Concern
  
  ##############################################################################
  # Cancels the *order*
  # Returns error message or nil
  ##############################################################################
  def cancel_order order
    if order.x_id.nil?
      order.error  = "Can't be canceled without EX ID"
      order.status = 'wrong'
    else
      response  = ZtBtce.cancel_order order_id: order.x_id

      if order.x_id == response['return']['order_id']   # be on the safe side
        pair_name     = order.run.pair.name
        order.x_base  = response['return']['funds'][pair_name.split('_').first]
        order.x_quote = response['return']['funds'][pair_name.split('_').first]
        order.error   = nil
        order.status  = 'canceled'
      else                                            # Something went wrong
        order.error  = "EX_ID #{order.x_id} mismatched to WEX_ID #{response['return']['order_id']}"
        order.status = 'wrong'
      end
    end
    
    order.save!
    if order.error.present?
      "Order #{order.id}: #{order.error}"      # Return error message 
    else
      nil
    end
  end
  
  ##############################################################################
  # Cancels all Run's active Orders including Fix Order if any
  ##############################################################################
  def cancel_orders run
    orders_active = run.orders.active
    
    if orders_active.present?
      orders_active.each do |order|
        fix_order = order.fix_order
        cancel_order fix_order if fix_order.active?
        cancel_order order
      end
    end
  end
  
  ##############################################################################
  # Checks *fix_order*
  # 
  # # NB! Trade API method 'Trade' accepts *THREE* decimal digits for *price* only: round(3) to be applied!
  ##############################################################################
  def check_fix_order order
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
      FixOrder.create run_id: order.run.id, rate: order.fix_rate, amount: order.fix_amount 
  end
  
  # Creates all Orders for the Run
  def create_orders run
    orders = run.kind == 'buy' ? set_orders_buy(run) : set_orders_sell(run)
    
    for i in 0...run.orders_number
      Order.create run_id: run.id, rate: orders[i]['rate'], amount: orders[i]['amount'], 
                   fix_rate: orders[i]['fix_rate'], fix_amount: orders[i]['fix_amount']
    end
  end

  ##############################################################################
  # Places *order* (fix = false) or *fix_order* (fix = true)
  # 
  # # NB! Trade API method 'Trade' accepts *THREE* decimal digits for *price* only: round(3) to be applied!
  ##############################################################################
  def place_order order, fix = false

    if fix
      run  = order.order.run                        # FixOrder.Order.Run
      type = (run.kind == 'buy') ? 'buy' : 'sell'   # opposite to Run's kind
    else
      run  = order.run                              # Order.Run
      type = (run.kind == 'sell') ? 'sell' : 'buy'
    end
    
    pair_name = run.pair.name
    response  = ZtBtce.trade pair: pair_name, type: type, rate: order.rate.round(3), amount: order.amount

    if response['success'] == 0                             # Error
      order.status = 'rejected'
      order.error  = response['error']
    else                                                    # Order has been placed
      order.x_id          = response['return']['order_id']
      order.x_done_amount = response['return']['received']
      order.x_rest_amount = response['return']['remains']

      order.x_base  = response['return']['funds'][pair_name.split('_').first]
      order.x_quote = response['return']['funds'][pair_name.split('_').first]

      if order.x_id == 0          # Order was fully 'matched' if its id = 0
        order.status = 'rejected'
        order.error  = "Order was fully 'matched'"
      else
        order.status = 'active'
        order.error  = nil
      end
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
  #  Creates Order rates array and calculates first and last elements
  ##############################################################################
  def initiate_rates run
    rates     = Array.new(run.orders_number - 1)
    kind       = set_kind run.kind
    rates[0]  = run.last    * (1.0 + kind * run.indent  / 100.0)
    rates[-1] = rates.first * (1.0 + kind * run.overlap / 100.0)

    rates
  end
    
  ##############################################################################
  #  Sets *kind* value for orders calculation
  ##############################################################################
  def set_kind kind
#    kind == 'sell' ? -1 : 1
    kind == 'buy' ? -1 : 1
  end

  ##############################################################################
  #  Calculates parameters of the *buy* Run's orders
  #  
  #  Parameters:
  #   
  ##############################################################################
  def set_orders_buy run
  #####   Coefficients    #####
    m     = 1.0 + run.martingale / 100.0    # Martingale factor
    m_sum = 0                               # Sum_of(m-ith) aka geometric progression sum
    a_sum = 0                               # Sum of orders amounts
    f     = run.pair.fee / 100.0
    p     = run.profit   / 100.0

  # Initialize Arrays
    orders           = Array.new(run.orders_number)  # orders hashes 
    rates            = Array.new(run.orders_number)  # Orders rates (prices)
    transactions     = Array.new(run.orders_number)  # Orders transactions (volumes) T = Sum(RA)
    amounts          = Array.new(run.orders_number)  # Orders amounts - in base currency (e.g. BTC)
    fix_amounts      = Array.new(run.orders_number)  # Fix Orders amounts
    fix_transactions = Array.new(run.orders_number)  # Fix Orders transactions
    fix_rates        = Array.new(run.orders_number)  # Fix Orders rates (prices)
    
    #####   Calculate Orders Rates   #####
    if run.scale == 'linear'
      rates = set_rates_linear run
    else
      rates = set_rates_pseudo_logarithmic run
     #rates = set_rates_logarithmic run
    end

    #####   Calculate Orders Transactions & Amounts   #####
    for i in 0...run.orders_number
      m_sum += m**i
    end

    transactions[0] = run.depo / m_sum                    # T0
    amounts[0]      = transactions[0] / rates[0]          # A0

    trans_per_order    = []                               # Transaction for each order
    trans_per_order[0] = transactions[0]
    for i in 1...run.orders_number
      trans_per_order[i] = trans_per_order[i-1] * m       # It's a geometrical progression
      amounts[i]         = trans_per_order[i]   / rates[i]
      transactions[i]    = transactions[i-1]    + trans_per_order[i]
    end

    #####   Fix Orders   #####
    for i in 0...run.orders_number
      a_sum              += amounts[i]
      fix_amounts[i]      = (1.0 - f) * a_sum                   # equals Orders base earned
      fix_transactions[i] = transactions[i] * (1.0 + p) / (1.0 - f)
      fix_rates[i]        = fix_transactions[i] / fix_amounts[i]
    end
 
    #####   Orders    #####
    for i in 0...run.orders_number
      order = {}
      order['rate']       = rates[i]
      order['amount']     = amounts[i]
      order['fix_rate']   = fix_rates[i]
      order['fix_amount'] = fix_amounts[i]
      orders[i]           = order
    end
    
    orders
  end
  
  ##############################################################################
  #  Calculates parameters of the *sell* Run's  orders
  #  
  #  Order's Fee:     Transaction * Fee
  #  FixOrder's Fee:  Amount * Fee
  #   
  ##############################################################################
  def set_orders_sell run
  #####   Coefficients    #####
    m     = 1.0 + run.martingale / 100.0    # Martingale factor
    m_sum = 0                               # Sum_of(m-ith) aka geometric progression sum
    a_sum = 0                               # Sum of orders amounts
    f     = run.pair.fee / 100.0
    p     = run.profit   / 100.0
    
  # Initialize Arrays
    orders           = Array.new(run.orders_number)  # orders hashes 
    rates            = Array.new(run.orders_number)  # Orders rates (prices)
    transactions     = Array.new(run.orders_number)  # Orders transactions (volumes) T = Sum(RA)
    amounts          = Array.new(run.orders_number)  # Orders amounts - in base currency (e.g. BTC)
    fix_amounts      = Array.new(run.orders_number)  # Fix Orders amounts
    fix_transactions = Array.new(run.orders_number)  # Fix Orders transactions
    fix_rates        = Array.new(run.orders_number)  # Fix Orders rates (prices)
    
    #####   Calculate Orders Rates   #####
    if run.scale == 'linear'
      rates = set_rates_linear run
    else
      rates = set_rates_pseudo_logarithmic run
     #rates = set_rates_logarithmic run
    end

    #####   Calculate Orders Amounts & Transactions  #####
    for i in 0...run.orders_number
      m_sum += m**i
    end
    
    a_max           = run.depo / rates[0]    # Potentially max Amount could be sold to earn the Depo
    amounts[0]      = a_max / m_sum
    transactions[0] = rates[0] * amounts[0]
  
    trans_per_order    = []                               # Transaction for each order
    trans_per_order[0] = transactions[0]
    for i in 1...run.orders_number
      trans_per_order[i] = trans_per_order[i-1] * m       # It's a geometrical progression
      amounts[i]         = trans_per_order[i]   / rates[i]
      transactions[i]    = transactions[i-1]    + trans_per_order[i]
    end
    
    #####   Fix Orders   #####
    for i in 0...run.orders_number
#      fix_transactions[i] = transactions[i] * (1 - f)   # Fee is deducted
      fix_amounts[i]      = amounts[i] * (1 + f)        # Further FixOrder Fee is taken into account
      fix_rates[i]        = trans_per_order[i] * (1 + p) / amounts[i] / (1 - f*f)
    end
      
     #####   Orders    #####
    for i in 0...run.orders_number
      order = {}
      order['rate']       = rates[i]
      order['amount']     = amounts[i]
      order['fix_rate']   = fix_rates[i]
      order['fix_amount'] = fix_amounts[i]
      orders[i]           = order
    end
    
    orders
  end
  
  ##############################################################################
  #  Generates orders rates with linear scale:
  #   rate[i] = rate[i-1] + delta
  #   n - orders_number
  ##############################################################################
  def set_rates_linear run
    rates = initiate_rates(run)
    delta  = (rates.last - rates.first) / (run.orders_number - 1)

    for i in (1...run.orders_number)
      rates[i] = rates[i-1] + delta
    end
    
    rates
  end

  # This is for testing only
  def set_rates_logarithmic_test run
#    rates = Array.new(run.orders_number)
    [1535.523, 1519.899, 1500.775, 1476.121, 1441.373, 1381.971]
  end
  
  
  def set_rates_logarithmic run
    rates = initiate_rates(run)    
  end
  
  ##############################################################################
  #  Generates orders rates with pseudo-logarithmic scale:
  #  price[i] = price[i-1] * i * diff
  #  where diff = (price_max - price_min) / sum_of arithmetic_progression
  #        sum_of arithmetic_progression = (0+(n-1))/2 *n = n*(n-1)/2
  #        n - orders_number
  ##############################################################################
  def set_rates_pseudo_logarithmic run
    rates = initiate_rates(run)
    arithm_progr_sum = run.orders_number * (run.orders_number - 1) / 2.0    # sum = n/2*(n-1)
    elemenrtary_diff = (rates.last - rates.first) / arithm_progr_sum
    for i in 1...run.orders_number
      rates[i] = rates[i-1] + elemenrtary_diff * i
    end
    rates
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
  
  ##############################################################################
  # Validates order attributes:
  #   If *sell* base validate its amount
  #   If *buy* base validate quote rates
  ##############################################################################
  def valid? order          # Obsolete
    run  = order.run.pair
    pair = run.pair
    
    if run.kind == 'ask'
      if order.amount >= pair.min_amount #and order.amount 
        false
      else
        true
      end
    else
      if order.price < pair.min_price or order.price > pair.max_price
        false
      else
        true
      end
    end
  end
end

