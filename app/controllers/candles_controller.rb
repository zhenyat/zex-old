class CandlesController < ApplicationController
  include CandlesPro
  
  def add
    @time_elapsed = []
    
#   collection = Collection.fifth           # for testing
    Collection.active.each do |collection|
      t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      pair_id           = collection.pair.id
      slot              = collection.slot      
      candle_timestamps = []
      
      if collection.candles.present?
        first_timestamp = collection.candles.last.start_stamp + slot
        trades          = Trade.where("pair_id = ? AND timestamp >= ?", pair_id, first_timestamp).order(:timestamp)
 
      candle_timestamps[0] = first_timestamp
      else
        trades = Trade.where(pair_id: pair_id).order(:timestamp) # Select all trades
        
        first_timestamp      = trades.first.timestamp
        candle_timestamps[0] = collection_starting_timestamp first_timestamp, slot
      end
      candle_timestamps[1] = candle_timestamps[0] + slot

      # Create Candles
      while candle_timestamps.first <= Time.now.to_i
        candle_trades = trades.where("timestamp >= ? AND timestamp < ?", candle_timestamps.first, candle_timestamps.last)

        if candle_trades.present?
          create_candle collection.id, candle_trades, candle_timestamps.first
        end  
        candle_timestamps[0] += slot
        candle_timestamps[1] += slot
      end
      t_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @time_elapsed[collection.id] = (t_finish - t_start).round(2)
    end
  end
  
  def index
    
  end
end
