class FundsValidator < ActiveModel::Validator
  include AccountPro
  include DataPro

  # Run validation
  def validate record
    if record.depo.present?
      data  = get_account_data
      pair  = record.pair
      coins = pair.name.split('_')

      if record.kind == 'sell'                               # Validate base currency value
        coin     = coins.first
        ticker   = get_ticker pair.name
        base_max = record.depo / ticker.first.last['high'] # Maximum amount to be sold
        if base_max > data['funds'][coin]
          record.errors[:depo] << "Small #{coin.upcase} balance: #{data['funds'][coin]}"
        end
        
        if base_max < pair.min_amount
          record.errors[:depo] << "#{coin.upcase} to small amount: #{pair.min_amount}"
        end
      else                                                   # Validate quote currency value 
        coin = coins.second
        if record.depo > data['funds'][coin]
          record.errors[:depo] << "Small #{coin.upcase} balance: #{data['funds'][coin]}"
        end
      end
    end
  end
end
