module CandlesPro
  extend ActiveSupport::Concern
  
  ##############################################################################
  # Creates Candle for *trades* of selected *collection* 
  #                with time frame starting at *start_stamp*
  ##############################################################################
  def create_candle collection_id, trades, timestamp
  
    open   = trades.first.price.to_f     # BigDecimal to Float - MUST BE DONE!
    close  = trades.last.price.to_f
    low    = trades.minimum(:price).to_f
    high   = trades.maximum(:price).to_f

    amount_sold   = trades.where(kind: 'sell').sum(&:amount).to_f
    amount_bought = trades.where(kind:  'buy').sum(&:amount).to_f
          
    sales = trades.where(kind: 'sell').count
    buys  = trades.where(kind:  'buy').count

    Candle.create! collection_id: collection_id, start_stamp: timestamp, 
                   open: open, close: close, low: low, high: high, 
                   amount_bought: amount_bought, amount_sold: amount_sold,
                   buys: buys, sales: sales
  end
  
  # Starting timestamp for candlesticks collection: slot, next to rounded timestamp
  def collection_starting_timestamp timestamp, slot
#    timestamp / slot * slot + slot
    Time.parse("2018-06-13 00:00").to_i
  end
end