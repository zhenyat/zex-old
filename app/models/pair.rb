class Pair < ApplicationRecord
  has_many   :trades
  
  belongs_to :base,  class_name: 'Coin'
  belongs_to :quote, class_name: 'Coin'
  
  enum status: %w(active archived)
end
