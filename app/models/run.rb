################################################################################
# Model:  Run
#
# Purpose:  Task Run to generate and handle a set of Orders
#
# Run attributes:
#   pair       - Foreign key
#   kind       - strategy type:                 enum { ask (sell) (0) | bid (buy) (1) }
#   depo       - amount to be applied for Run:  decimal
#   last       - last closed trade price:       decimal
#   indent     - price step to first order, %0: float
#   overlay    - price overlay (last_order - first_order) %:   float
#   martingale -  in %:                         float
#   orders     - number of orders:              integer
#   profit     - in %:                          float
#   scale      - order prices range scale:      enum { linear (0) | logarithmic (1) }
#   stop_loss  - stop loss:                     decimal
#   status     - Run status:  enum {created (0) | active (1) | executed (2) | canceled (3))}
#   
#  16.01.2018   ZT
#  27.02.2018   status updated & dependency added
################################################################################
class Run < ApplicationRecord
  belongs_to :pair
  has_many   :orders,     dependent: :destroy 
  
  enum kind:   %w(ask bid)
  enum scale:  %w(linear logarithmic)
  enum status: %w(created active executed canceled)
  
  validates :depo, presence: true
end