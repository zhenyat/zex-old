################################################################################
# Data Processing module
#
#   02.01.2018  Last Update
#   08.02.2018  Updated for zex
#   03.02.2018  Method *set_time_frame*'= was modified
################################################################################
module DataPro
  extend ActiveSupport::Concern
  
  ##############################################################################
  #  Adds ans saves trade data from the site for the given Pair
  #
  #  26.12.2017  ZT
  #  02.01.2018  Last update
  #  08.02.2018  Updated for zex
  ##############################################################################
  def add_trades pair, limit=5000
    
    max_tid   = Trade.where(pair_id: pair.id).maximum(:tid)
    max_tid   = 0 if max_tid.nil? 
    add_count = 0
    
    ### Get data from the Site
    
    trades = ZtBtce.trades pairs: pair.name, limit: limit  # Hash of deals for key 'pair'
    deals  = trades.values.first.reverse                   # new deals as a hash array (last - the latest tid) 

    ### Save data 
    deals.each do |deal|
      if deal['tid'] > max_tid
        kind = (deal['type'] == 'ask') ? 0 : 1
        Trade.create! pair_id: pair.id,       kind: kind,        price:     deal['price'],
                      amount: deal['amount'], tid:  deal['tid'], timestamp: deal['timestamp']
        add_count += 1 
      end
    end
  end

  ##############################################################################
  #  Gets 'cashed data' from a file
  #  Returns an array of candles
  #
  #  26.12.2017   ZT
  ##############################################################################  
  def fetch_cashed_data  pair_name
    filename = set_filename pair_name
    
    if File.exists? filename
      JSON.parse File.read filename # get existing data from the file
    else
      [false, "Error: the file '#{filename}' doesn't exists"]
    end
  end

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
    data = []
    price_min   = trades.minimum(:price).to_f       # BigDecimal to Float - MUST BE DONE!
    price_max   = trades.maximum(:price).to_f
    price_first = trades.first.price.to_f
    price_last  = trades.last.price.to_f
    amount_tot  = trades.sum(&:amount).to_f

    data << Time.at(time_frame.first).strftime('%d-%m-%Y %H:%M')
    data << price_min
    data << price_first
    data << price_last
    data << price_max
    data << (price_max + price_min + price_last) / 3  # to be presented as 2nd chart
    data << amount_tot                                # to be presented as 3rd chart
    
    data
  end

  def get_ticker pair_name
    ZtBtce.ticker pairs: pair_name 
  end
  
  # Selects data filr to be processed
  def set_filename pair_name
    File.join(Rails.application.root, 'data', pair_name + '.txt')  # aka btc_usb.txt
  end
   
  ##############################################################################
  #  Sets the trade model name (e.g. BtcTrade) for a given *pair_name*
  #
  #  02.01.2018   ZT
  #  08.02.2018   Obsolete for zex
  ##############################################################################
  def set_model_name pair_name='btc_usd'
    "#{pair_name.split('_').first.capitalize}Trade".constantize
  end
  
  ##############################################################################
  #  Sets time frame, nearest to argument time
  #
  #  29.12.2017   ZT
  #  03.02.2018   Modified
  ##############################################################################  
  def set_time_frame time, time_slot = 30.minutes
    time_frame = []
    time_frame[0] = (time.to_i / time_slot).round * time_slot
#    time_frame[0] = Time.at(((time.to_i / time_slot).round * time_slot) + time_slot).to_i
    time_frame[1] = time_frame[0] + time_slot
    time_frame
  end

  ##############################################################################
  #  Stores candles array as a 'cash' into a file for a given pair
  #
  #  26.12.2017   ZT
  ##############################################################################  
  def store_cashed_data pair_name, data_array
    fin = File.open set_filename(pair_name), "w"
    fin.puts data_array.to_json
    fin.close    
  end

  # Obsolete for zex
  def store_last_trades pair_name
    model = set_model_name pair_name
    last_trades    = []
    last_trades[0] = model.last_sold
    last_trades[1] = model.last_bought

    fout = File.open File.join(Rails.application.root, 'data', pair_name + '_last.txt'), 'w'
    fout.puts last_trades.to_json
    fout.close
  end

  # Rounds the given *time* to nearest time *slot*
  def time_round(time, slot = 30.minutes)
    Time.at((time.to_i / slot).round * slot)
  end
 
  ##############################################################################
  #  Updates 'cashed data' in a file
  #
  #  26.12.2017   ZT
  #  08.02.2018   Obsolete
  ##############################################################################  
  def update_cashed_data  pair_name, data_array
#    filename = set_filename pair_name
#
#    if File.exists? filename
#      candles = File.read filename  # get existing data from the file
#      candles.shift                 # remove first element
#      candles.pop                   # remove last  element (to be replaced)
#      candles << data_array.last    # add updated last element
#    else
#      candles = data_array          # initial data to be stored
#    end
  end
  
  ##############################################################################
  #  Updates cashed candlesticks data
  #
  #  03.01.2018   ZT
  #  TBU for ActiveJob
  ##############################################################################
  def update_candlesticks pair_name
      data = fetch_cashed_data pair_name
      
      data.delete_if {|d| d.first.to_time < time_round((Time.now - (PERIOD + TIME_SLOT)), TIME_SLOT)}   # Remove candles out of range

      candle_last = data.pop                     # Remove last candle (cause it could not be finalized)
      since       = candle_last.first.to_time

      model = set_model_name pair_name
      trades = model.where('timestamp >= ?', since.to_i).order(:tid)  # Add new trades

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
  end
end
