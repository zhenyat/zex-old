################################################################################
# Model:  Trade
#
# Purpose:  Trades collected from WEX
#
# Run attributes:
#   pair       - Foreign key
#   kind       - Trade type                     enum {sell (0)| buy (1)}
#   rate       - Price to be bought / sold at   decimal
#   amount     - Amount to be bought / sold     decimal
#   tid        - WEX Trade ID                   integer
#   timestamp  - Trade timestamp                integer
#      
#   15.03.2018  ZT (revised version)
#   15.04.2018  New revision
################################################################################
class Trade < ApplicationRecord
  belongs_to :pair
  
  enum kind: %w(sell buy)
  
#  where(id: ARRAY_COLLECTION.map(&:id))
# => MyModel.where(id: arr.map(&:id))
end
