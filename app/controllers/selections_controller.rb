class SelectionsController < ApplicationController
  include DataPro
  
  def new
  end

  def charts
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    
    @pair       = Pair.find(params['selection']['pair'].to_i)
    @time_first = Time.new  params['selection']['time_first(1i)'].to_i, params['selection']['time_first(2i)'].to_i, params['selection']['time_first(3i)'].to_i, params['selection']['time_first(4i)'].to_i, params['selection']['time_first(5i)'].to_i
    @time_last  = Time.new  params['selection']['time_last(1i)'].to_i,  params['selection']['time_last(2i)'].to_i,  params['selection']['time_last(3i)'].to_i,  params['selection']['time_last(4i)'].to_i,  params['selection']['time_last(5i)'].to_i

    @time_slots = [60, 120, 300, 600, 900, 1800]  # seconds
    trades = Trade.where('pair_id = ? AND timestamp >= ? AND timestamp <= ?', @pair.id, @time_first.to_i, @time_last.to_i,).order(:timestamp)

    candles = []
    @time_slots.each_with_index do |time_slot, index|
      candles[index] = []
      time_frame     = []         # Limits of time frame (min / max)
      time_frame     = (set_time_frame @time_first, time_slot)

      while time_frame.first <= @time_last.to_i

        candle_trades = trades.where('timestamp >= ? and timestamp < ?', time_frame.first, time_frame.last).order(:timestamp)

        candles[index] << form_candle(candle_trades, time_frame) if candle_trades.present?

        time_frame[0] += time_slot
        time_frame[1] += time_slot
      end
    end

    gon.candles    = candles
    gon.time_slots = @time_slots
    gon.period     = (@time_last - @time_first) / 60  # minutes

    t_finish      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @time_elapsed = (t_finish - t_start).round(2)
  end
end
