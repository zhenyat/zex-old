class Candle < ApplicationRecord
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
  
  def lower_shadow
    (open >= close) ? close - low  : open - low
  end
  
  def type
    (open >= close) ? 'bea' : 'bull'
  end
  
  def upper_shadow
    (open >= close) ? high - open  : high - close
  end
end
