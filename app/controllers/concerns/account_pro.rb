################################################################################
# Account data Processing module
#
#   26.03.2018
#   09.04.2018  Corrected (output is a hash)
#   22.05.2018  Data emulation added
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

    data['funds'] = Hash[data['funds'].sort_by {|key, value| key}]  # Sorting by coin
    
    # Data Emulation
    if EMULATION
      Pair.active.each do |pair|
        coin = pair.base.code.downcase
        data['funds'][coin] = 1.0
      end
      data['funds']['usd'] = 2000.0
    end

    data
  end
end