class Trade < ApplicationRecord
  belongs_to :pair
  
#  where(id: ARRAY_COLLECTION.map(&:id))
# => MyModel.where(id: arr.map(&:id))
end
