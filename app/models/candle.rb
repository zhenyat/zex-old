class Candle < ApplicationRecord
  belongs_to :collection
  
  validates :open,  presence: true, numericality: { greater_than: 0 }
  validates :close, presence: true, numericality: { greater_than: 0 }
  validates :low,   presence: true, numericality: { greater_than: 0 }
  validates :high,  presence: true, numericality: { greater_than: 0 }
  
  def amount
    self.amount_bought + self.amount_sold
  end
  
  def average
    (self.high + self.low + self.close) / 3
  end
  
  def body
    (self.close - self.open).abs
  end
  
  def lower_shadow
    (self.open >= self.close) ? self.close - self.low  : self.open - self.low
  end
  
  def type
    (self.open >= self.close) ? 'buy' : 'sell'
  end
  
  def upper_shadow
    (self.open >= self.close) ? self.high - self.open  : self.high - self.close
  end
end
