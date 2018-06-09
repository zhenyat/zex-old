################################################################################
# Model:  Pattern
#
# Purpose:  Candlestick patterns
#
# Pattern attributes:
#   name        - Pattern's name:                     string
#   title       - Pattern's title:                    string
#   mix         - Number of candles in thh pattern:   enum
#   description - Pattern description:                text
#   icon        - Pattern image (cw uploader)
#   status      - Run status:                         enum {active (0) | archived (1)}
#   
#   08.05.2018  ZT
################################################################################
class Pattern < ApplicationRecord
  mount_uploader :icon, IconUploader
  
  enum mix:    %w(one two three)
  enum status: %w(active archived)
  
  validates :name,  presence: true, uniqueness: true
  validates :title, presence: true
end
