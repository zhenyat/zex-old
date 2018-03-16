################################################################################
# Model:  FixOrder
#
# Purpose:  Fix Order generated for Run 
#
# Run attributes:
#   order      - Foreign key
#   price      - Price to be sold /bought at:           decimal
#   amount     - Amount to be sold /bought:             decimal
#   error      - error message from the Server          string
#   status     - Run status:  enum {active (0)executed (1)|canceled (2)|canceled_but_partly_executed (3) |created (4)|active (1)|rejected (5)|}
#
#   Ex Order values (if nil - not placed yet):
#   x_id          - Order ID assigned at the stockEx:                    string
#   x_pair        - Pair on which the order was created:                 string
#   x_type        - Order type:                                          eenum {buy | sell}
#   x_done_amount - The initial amount at the time of order creation:    decimal
#   x_rest_amount - The remaining amount of currency to be bought/sold:  decimal
#   x_rate        - Sell/Buy price:                                      decimal
#   x_timestamp   - The time when the order was created:                 integer
#   x_base        - Fund of base  carrency:                              decimal
#   x_quote       - Fund of quote carrency:                              decimal
#   x_status      - Order status:  enum {active (0)|executed (1)|canceled (2)|canceled_but_partly_executed (3)}
#
#  15.03.2018   ZT (revised version)
###############################################################################
class FixOrder < ApplicationRecord
  belongs_to :order
  
  enum status:   %w(active executed canceled canc_partly_executed created rejected)
  enum x_type:   %w(sell buy)
  enum x_status: %w(x_active x_executed x_canceled x_canc_partly_executed)
end
