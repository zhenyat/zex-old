module RunsHelper
  
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
