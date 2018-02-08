################################################################################
# Model:  Run
#
# Purpose:
#
# Run attributes:
#   coin       - Foreign key
#   kind       - strategy type:             enum { ask (sell) (0) | bid (buy) (1) }
#   depo       - amount to be used:         decimal
#   last       - last closed trade price:   decimal
#   start      - price step to first order %: float
#   overlay    - price overlay (first - last orders) %:   float
#   martingale -  %:                        float
#   orders     - number of orders:          integer
#   profit     - in %:                      float
#   scale      - order prices range ascale: enum { linear (0) | logarithmic (1) }
#   stop_loss  - stop loss:                 decimal
#   status     - Run status:                enum { opened (0) | closed (1) | aborted (2) }
#   
#  16.01.2018 ZT
################################################################################
class Run < ApplicationRecord
  belongs_to :pair
  
  enum kind:   %w(ask bid)
  enum scale:  %w(linear logarithmic)
  enum status: %w(opened closed aborted)
end