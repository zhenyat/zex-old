
# https://www.sitepoint.com/community/t/referencing-the-same-model-twice-in-rails/254243

class Coin < ApplicationRecord
  has_many :based_pairs,  class_name: 'Pair', foreign_key: 'base_id'
  has_many :quoted_pairs, class_name: 'Pair', foreign_key: 'quote_id'
  
  enum status: %w(active archived)
end
