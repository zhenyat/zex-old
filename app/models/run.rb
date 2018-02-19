################################################################################
# Model:  Run
#
# Purpose:
#
# Run attributes:
#   pair       - Foreign key
#   kind       - strategy type:                 enum { ask (sell) (0) | bid (buy) (1) }
#   depo       - amount to be applied for Run:  decimal
#   last       - last closed trade price:       decimal
#   indent     - price step to first order (%0: float
#   overlay    - price overlay (last_order - first_order) %:   float
#   martingale -  in %:                         float
#   orders     - number of orders:              integer
#   profit     - in %:                          float
#   scale      - order prices range scale:      enum { linear (0) | logarithmic (1) }
#   stop_loss  - stop loss:                     decimal
#   status     - Run status:                    enum { opened (0) | closed (1) | aborted (2) }
#   
#  16.01.2018 ZT
################################################################################
class Run < ApplicationRecord
  has_many   :orders
  belongs_to :pair
  
  enum kind:   %w(ask bid)
  enum scale:  %w(linear logarithmic)
  enum status: %w(opened closed aborted)
end