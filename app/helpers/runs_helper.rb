module RunsHelper
  
  def fix_transaction order
    order.fix_rate * order.fix_amount
  end
  
  def order_status status
    case status
    when 0
      "Generated"
    when 1
      "Active"
    when 2
      "Executed"
    when 3
      "Canceled"
    when 4
      "Canceled / Executed partly"
    end
  end
    
  # Quote to earn by Fix Order
  def quote_to_earn order
    fix_transactions = 0
    
    order.run.orders.each do |o|
      if o.id <= order.id
        if order.run.kind == 'buy'
          fix_transactions  = o.fix_rate * o.fix_amount
        else 
          fix_transactions += o.fix_rate * o.fix_amount
        end
      end
    end
    fix_transactions * (1.0 - order.run.pair.fee / 100.0)
  end
  
  def quote_profit order
    transactions     = 0
    fix_transactions = 0
    
    order.run.orders.each do |o|
      if o.id <= order.id
        if order.run.kind == 'buy'
          fix_transactions  = o.fix_rate * o.fix_amount
        else
          fix_transactions += o.fix_rate * o.fix_amount
        end
        transactions     += o.rate * o.amount
      end
    end
    fix_transactions * (1.0 - order.run.pair.fee / 100.0) - transactions
#    else
#      order.run.orders.each do |o|
#        if o.id <= order.id
#          transactions    += o.rate * o.amount
#          fix_transactions = o.fix_rate * o.fix_amount
#        end
#      end
#      return fix_transactions * (1.0 - order.run.pair.fee / 100.0) - transactions
  end
  
  #  Quote to spend per Order
  def quote_to_spend order
    order.rate * order.amount
  end
  
  def quote_unit
    case @run.pair.quote.code
    when 'EUR'
      '€'
    when 'RUR'
      '₱'
    when 'USD'
      '$'
    else
      ''
    end
  end
  
  def run_status status
    case status
    when 0
      "Generated"
    when 1
      "Active"
    when 2
      "Executed"
    when 3
      "Canceled"
    end
  end
end
