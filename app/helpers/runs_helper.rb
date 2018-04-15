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
  
  # Quote to earn per Fix Order
  def quote_earned order
    order.fix_rate * order.fix_amount * (1.0 - order.run.pair.fee / 100.0)
  end
  
  #  Quote to spend per Order
  def quote_spent order
    order.rate * order.amount
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
