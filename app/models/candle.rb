################################################################################
# Model:  Candle
#
# Purpose:  Candlestick class 
#
# Candle attributes:
#   collection    - Foreign key
#   start_stamp   - Candle's initial timestamp: integer
#   open          - Open price:                 decimal
#   close         - Closing price               decimal
#   low           - Lowest price:               decimal
#   high          - Highest price:              decimal
#   amount_bought - Total amount of buys:       decimal
#   amount_sold   - Total amount of sales       decimal
#   buys          - Number of buy trades:       integer
#   sales         - Number of sell trades:      integer
#      
#   04.06.2018  
################################################################################
     
class Candle < ApplicationRecord
#  attr_accessor :amount, :amount_bought, :amount_sold, :close, :color, :high, :low, :open, :start_time
  
  belongs_to :collection
  
  validates :open,  presence: true, numericality: { greater_than: 0 }
  validates :close, presence: true, numericality: { greater_than: 0 }
  validates :low,   presence: true, numericality: { greater_than: 0 }
  validates :high,  presence: true, numericality: { greater_than: 0 }
  
  def amount
    amount_bought + amount_sold
  end
  
  def average
    (high + low + close) / 3
  end
  
  def body
    (close - open).abs
  end
  
  def color
    (open >= close) ? 'red' : 'green'
  end
  
  def doji?
    body < EQUAL_PERCENT / 100.0 * [close, open].min
  end
    
  def lower_shadow
    (open >= close) ? close - low  : open - low
  end
  
  def type
    (open >= close) ? 'bear' : 'bull'
  end
  
  def upper_shadow
    (open >= close) ? high - open  : high - close
  end
end
