################################################################################
# Model:  Order
#
# Purpose:  Order generated for Run 
#
# Run attributes:
#   run        - Foreign key
#   ex_id      - Order number assigned at the stockEx:  integer  (if nil - not placed yet)
#   price      - Price to be sold /bought at:           decimal
#   amount     - Amount to be sold /bought:             decimal
#   wavg_price - Weighted Average Price:                decimal
#   fix_price  - Fix Order Price:                       decimal
#   fix_amount - Amount versus: to be bought / sold     decimal
#   status     - Run status:  enum {active (0)executed (1)|canceled (2)|canceled_but_partly_executed (3) |created (4)|active (1)|rejected (5)|}
#   
#  27.02.2018   ZT
#  07.03.2018   fix_amount added
################################################################################
class Order < ApplicationRecord
  belongs_to :run
  
  enum status: %w(active executed canceled partly_executed created rejected)
end
