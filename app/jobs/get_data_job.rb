class GetDataJob < ApplicationJob
  queue_as :default

  include DataPro
  
  def perform
    Pair.active.each do |pair|      
      add_trades pair, 2000 
    end
  end
end
