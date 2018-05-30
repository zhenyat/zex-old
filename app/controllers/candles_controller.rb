class CandlesController < ApplicationController
  include CandlesPro
  
  def index
    @time_elapsed = []
    
#    collection = Collection.fifth
    Collection.active.each do |collection|
      t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      
      pair_id = collection.pair.id
      slot    = collection.slot
      trades  = Trade.where(pair_id: pair_id).order(:timestamp)
      
      first_timestamp      = trades.first.timestamp
      candle_timestamps    = []
      candle_timestamps[0] = collection_starting_timestamp first_timestamp, slot
      candle_timestamps[1] = candle_timestamps[0] + slot

      # Create Candle
      while candle_timestamps.first <= Time.now.to_i
        candle_trades = trades.where("timestamp >= ? AND timestamp < ?", candle_timestamps.first, candle_timestamps.last)

        if candle_trades.present?
          open   = candle_trades.first.price.to_f     # BigDecimal to Float - MUST BE DONE!
          close  = candle_trades.last.price.to_f
          low    = candle_trades.minimum(:price).to_f
          high   = candle_trades.maximum(:price).to_f
          
          amount_sold   = candle_trades.where(kind: 0).sum(&:amount).to_f
          amount_bought = candle_trades.where(kind: 1).sum(&:amount).to_f
          
          sales = candle_trades.where(kind: 0).count
          buys  = candle_trades.where(kind: 1).count
          
          Candle.create! collection_id: collection.id,
                         start_time: Time.at(candle_timestamps.first).in_time_zone.strftime('%d-%m-%Y %H:%M'),
                         open: open, close: close, low: low, high: high, 
                         amount_bought: amount_bought, amount_sold: amount_sold,
                         buys: buys, sales: sales
        end  
        candle_timestamps[0] += slot
        candle_timestamps[1] += slot

      end
      t_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @time_elapsed[collection.id] = (t_finish - t_start).round(2)
      puts "===== ZT! #{collection.id} - #{@time_elapsed[collection.id]}"
    end
  end
end
