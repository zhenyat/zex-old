class Collection < ApplicationRecord
  belongs_to :pair
  has_many   :candles
  
#  enum slot:   %w(1 3 5 15 30 60)   # minutes
#  enum slot:    [60, 180, 300, 900, 1800, 3600]
  enum status: %w(active archived)
  
  validates :pair,  uniqueness: { scope: :slot }
end
