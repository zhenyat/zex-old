class PatrecController < ApplicationController
#  before_action  :select_candles

  def doji
    @doji = []
    @candles.each do |candle|
      if candle.doji?
        @doji << candle
      end
    end
  end

  def index
    collection = Collection.find_by(pair_id: params['selection']['pair'], slot: params['selection']['slot'])
    @candles   = collection.candles
    @patterns  = params['selection']['patterns'].reject(&:empty?)

    @samples = []
    @patterns.each do |title|
      pattern = Pattern.find_by(title: title)
      id      = pattern.id
      method  = pattern.name + '?'
      @samples << []
      
      @candles.each do |candle|
        if candle.public_send(method)     # set method dynamically
          @samples.last << candle
        end
      end
    end
  end

  def new
    
  end
  
#  def select_candles
#    collection_id = Collection.find(4).id
#    @candles      = Candle.where(collection_id: collection_id)
#    
#  end
end
