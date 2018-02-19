class Pair < ApplicationRecord
  has_many   :trades
  has_many   :runs
  
  belongs_to :base,  class_name: 'Coin'
  belongs_to :quote, class_name: 'Coin'
  
  enum status: %w(active archived)
end
