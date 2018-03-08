################################################################################
# Model:  Order
#
# Purpose:  Order generated for Run 
#
# Run attributes:
#   run        - Foreign key
#   order_id   - Order number assigned at the stock:  integer  (if nil - not placed yet)
#   price      - Price to be sold /bought at:         decimal
#   amount     - Amount to be sold /bought:           decimal
#   wavg_price - Weighted Average Price:              decimal
#   fix_price  - Fix Order Price:                     decimal
#   fix_amount - Amount versus: to be bought / sold   decimal
#   status     - Run status:  enum { generated (0)|active (1)|rejected (2)|executed (3)|canceled (4)|canceled_or_executed_partly (5)}
#   
#  27.02.2018   ZT
#  07.03.2018   fix_amount added
################################################################################
class Order < ApplicationRecord
  belongs_to :run
  
  enum status: %w(generated active rejected executed canceled canc_or_exec_part )
end
