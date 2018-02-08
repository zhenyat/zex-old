class PagesController < ApplicationController
  include DataPro
  
  def home
    @domain = ZtBtce.get_domain
    @key    = ZtBtce.get_key
    
    asterisks =''
    for i in (0..59)
      asterisks[i]= '*'
    end
    @secret = "#{asterisks}#{ZtBtce.get_secret[-4..-1]}"
    
    @tickers = []
    
    Pair.active.each do |pair|
      pair_name = pair.name
      @tickers << get_ticker(pair_name)
    end
  end
end
