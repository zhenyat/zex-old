module CandlesPro
  extend ActiveSupport::Concern
  
  ##############################################################################
  #  Creates a candle for Trades in a given Time Frame
  #  Returns an array of a candle's data
  #  Array elements:
  #   - Time Frame low limit
  #   - Minimum price
  #   - First trade price
  #   - Last trade price
  #   - maximum price 
  #   - average price (https://developers.google.com/chart/image/docs/gallery/compound_charts)
  #   - Total amount
  #   
  #  27.12.2017   ZT
  #  14.02.2018   Total amount added
  ############################################################################## 
  def form_candle trades, time_frame
    data   = []
    low    = trades.minimum(:price).to_f       # BigDecimal to Float - MUST BE DONE!
    high   = trades.maximum(:price).to_f
    open   = trades.first.price.to_f
    close  = trades.last.price.to_f
    amount = trades.sum(&:amount).to_f

    data << Time.at(time_frame.first).in_time_zone.strftime('%d-%m-%Y %H:%M')
    data << price_min
    data << price_first
    data << price_last
    data << price_max
    data << (price_max + price_min + price_last) / 3  # to be presented as 2nd chart
    data << amount_tot                                # to be presented as 3rd chart
    
    data
  end
  
  # Starting timestamp for candlesticks collection: slot, next to rounded timestamp
  def collection_starting_timestamp timestamp, slot
    #timestamp / slot * slot + slot
    Time.parse("2018-05-30 10:00").to_i
  end
end