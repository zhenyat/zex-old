################################################################################
# Account data Processing module
#
#   26.03.2018  
################################################################################
module AccountPro
  extend ActiveSupport::Concern

  def get_account_data
    coins         = []
    data          = {}
    data['funds'] = {}
    
    response = ZtBtce.account_info
    
    data['open_orders'] = response['return']['open_orders']
    
    Pair.active.each do |pair|
      coins << pair.base.code.downcase
      coins << pair.quote.code.downcase
    end
    
    coins.uniq!
    coins.each do |coin|
      data['funds'][coin]  = response['return']['funds'][coin]
    end
    data['funds'] = data['funds'].sort
    data
  end
end