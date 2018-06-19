class TradesController < ApplicationController
  include DataPro
  
def candlesticks
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    period    = PERIOD + TIME_SLOT  # Period to select data for (last 24 hours, e.g from 15:00 to 15:00)
      
    # Resulting arrays
    pairs   = []
    candles = []
    
    Pair.active.each do |pair|
      pairs << pair.name
      trades = Trade.where('pair_id = ? AND timestamp >= ?', pair.id, (Time.now - period).to_i).order(:timestamp)
      
      data = fetch_cashed_data pairs.last   # data for current pair
      
      if data.first == false
        puts data.last          # Error message
      else
        candles << data
      end
    end

    # Resulting data for charts
    gon.pairs     = pairs
    gon.candles   = candles
    gon.time_slot = TIME_SLOT

    @pairs = pairs
    
    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)
  end
  
  # Creates cashed data files
  def create_cash
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

#   time_slot  = 30.minute
    period     = PERIOD + TIME_SLOT       # Period, data selected for (last 24 hours)

    @pairs         = []
    @candles_first = []
    @candles_last  = []
    
    Pair.active.all.each do |pair|
      pair_name = pair.name
      
      trades = Trade.where('pair_id = ? AND timestamp >= ?', pair.id, (Time.now - period).to_i).order(:timestamp)   # from lower to higher values
      
      time_frame = []         # Limits of time frame (min / max)
      time_frame = (set_time_frame (Time.now - period), TIME_SLOT)
 
      candles = []
      while time_frame.first <= Time.now.to_i

        candle_trades = trades.where('timestamp >= ? and timestamp < ?', time_frame.first, time_frame.last).order(:timestamp)

        candles << form_candle(candle_trades, time_frame) if candle_trades.present?

        time_frame[0] += TIME_SLOT
        time_frame[1] += TIME_SLOT
      end

      # Store result in a file
      store_cashed_data pair_name, candles
      
      # Show candles (first / last)
      @pairs         << pair_name
      @candles_first << candles.first
      @candles_last  << candles.last

    end
    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)
  end
  
  def create_tick_cash
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

#   time_slot = 1.minute
    period    = PERIOD + TIME_SLOT  # Period to select data for (last 24 hours, e.g from 15:00 to 15:00)
      
    # Resulting arrays
    pairs   = []
    candles = []

    Pair.active.all.each do |pair|
      pair_name = pair.name
      
      trades = Trade.where('pair_id = ? AND timestamp >= ?', pair.id, (Time.now - period).to_i).order(:timestamp)   # from lower to higher values
      
      trades.find_in_batches(batch_size: 200) do |tic_trades|
        time_first = tic_trades.first.timestamp
        candles << form_candle(tic_trades, time_first) if tic_trades.present?
      end
      
      # Store result in a file
      store_cashed_ticks pair_name, candles
      
      # Show candles (first / last)
      @pairs         << pair_name
      @candles_first << candles.first
      @candles_last  << candles.last

    end
    
    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)
  end
  
  def index
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    
    @trades_added = []
    # Add last trades
    Pair.active.each do |pair|
      count_before = Trade.where(pair_id: pair.id).count
      
      add_trades pair
      
      count_after = Trade.where(pair_id: pair.id).count
      @trades_added << count_after - count_before
    end

    # Show collected trades
    @trades = []
    @pairs  = []
    
    Pair.active.each do |pair|
      @pairs  << pair.name
      @trades << Trade.where('pair_id = ? AND timestamp >= ?', pair.id, (Time.now - 1.day).to_i).order(tid: :desc) 
    end

    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)
  end

def order_book
    @pairs = []
    @asks  = []
    @bids  = []
    
    Pair.active.each do |pair|
      @pairs << pair.name
      limit = 20
      depth = ZtBtce.depth pairs: @pairs.last, limit: limit
      @asks << depth.first.last['asks'].reverse
      @bids << depth.first.last['bids']
    end
  end

  # Update cashed data files with new candles
  def update_cash
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    period     = PERIOD + TIME_SLOT  # Period to select data for (last 24 hours, e.g from 15:00 to 15:00)

    @pairs         = []
    @candles_first = []
    @candles_last  = []
    
    Pair.active.each do |pair|
      pair_name = pair.name
      
      data = fetch_cashed_data pair_name
      
      data.delete_if {|d| d.first.to_time < time_round((Time.now - period), TIME_SLOT)}   # Remove candles out of range

      if data.present?
        @no_data    = false
        candle_last = data.pop                          # Remove last candle (cause it could not be finalized)
        since       = candle_last.first.to_time

        trades = Trade.where('pair_id = ? AND timestamp >= ?',pair.id, since.to_i).order(:tid)  # Add new trades

        time_frame = []                                 # Limits of time frame (min / max)
        time_frame = set_time_frame (since - TIME_SLOT), TIME_SLOT

        while time_frame.first <= Time.now.to_i

          candle_trades = trades.where('timestamp >= ? and timestamp < ?', time_frame.first, time_frame.last).order(:timestamp)

          if candle_trades.present?
            candle = form_candle(candle_trades, time_frame)
            data.push candle
          end

          time_frame[0] += TIME_SLOT
          time_frame[1] += TIME_SLOT
        end


        # Store updated data
        store_cashed_data pair_name, data

        @pairs         << pair_name
        @candles_first << data.first
        @candles_last  << data.last
        
      else                # No data: too much time past since last update...
        @no_data = true
      end
    end

    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)    
  end

  # https://www.topdogtrading.com/question-what-is-the-best-interval-for-day-trading/
  def tick_charts
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    
    period    = PERIOD + TIME_SLOT  # Period to select data for (last 24 hours, e.g from 15:00 to 15:00)
      
    # Resulting arrays
    @pairs     = []
    candles    = []
    time_frame = []  # required to meet form_candle args

    Pair.active.each_with_index do |pair, index|
      pair_name = pair.name
      candles[index] = []
      
      trades = Trade.where('pair_id = ? AND timestamp >= ?', pair.id, (Time.now - period).to_i).order(:timestamp)   # from lower to higher values
#      candles = form_tick_candles(trades) if trades.present?
      
      trades.find_in_batches(batch_size: 200) do |tic_trades|
        time_frame[0]  = tic_trades.first.timestamp
        new_trades = Trade.where(id: tic_trades.map(&:id))
        candles[index] << form_candle(new_trades, time_frame) if new_trades.present?
      end
      
      # Show candles (first / last)
      @pairs         << pair_name
#      @candles_first << candles.first
#      @candles_last  << candles.last
    end
    gon.pairs   = @pairs
    gon.candles = candles  
    
    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)
  end
end
