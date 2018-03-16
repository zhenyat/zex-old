class Pair < ApplicationRecord
  belongs_to :base,  class_name: 'Coin'
  belongs_to :quote, class_name: 'Coin'
  
  has_many   :trades
  has_many   :runs
  
  enum status: %w(active archived)
end
