class Trade < ApplicationRecord
  belongs_to :pair
  
  enum kind:   %w(buy sell)
  
#  where(id: ARRAY_COLLECTION.map(&:id))
# => MyModel.where(id: arr.map(&:id))
end
