################################################################################
# Model:  Order
#
# Purpose:  Order generated for Run 
#
# Order attributes:
#   run        - Foreign key
#   rate       - Price to be bought / sold at:          decimal
#   amount     - Amount to be bought / sold:            decimal
#   fix_rate   - Fix Order Price:                       decimal
#   fix_amount - Amount versus: to be sold / bought     decimal
#   error      - error message from the Server          string
#   status     - Run status:  enum {active(0)|executed(1)|canceled(2)|canceled_but_partly_executed(3)|created(4)|rejected(5)|wrong(6)}
#   
#   Ex Order values (if nil - not placed yet):
#   x_id          - Order ID assigned at the stockEx:                    string
#   x_pair        - Pair on which the order was created:                 string
#   x_type        - Order type:                                          enum {buy | sell}
#   x_done_amount - The amount of currency bought/sold:                  decimal
#   x_amount      - The remaining amount of currency to be bought/sold:  decimal
#   x_rate        - Buy/Sell price:                                      decimal
#   x_base        - Fund of base  carrency:                              decimal
#   x_quote       - Fund of quote carrency:                              decimal
#   x_timestamp   - The time when the order was created:                 integer
#   x_status      - Order status:  enum {active (0)|executed (1)|canceled (2)|canceled_but_partly_executed (3)}
#      
#   15.03.2018  ZT (revised version)
#   15.04.2018  New revision
################################################################################
class Order < ApplicationRecord
  belongs_to :run
  has_one    :fix_order, dependent: :destroy
  
  enum status:   %w(active executed canceled canc_partly_executed created rejected wrong)
  enum x_type:   %w(sell buy)
  enum x_status: %w(x_active x_executed x_canceled x_canc_partly_executed)
  
  validates_with FundsValidator
end