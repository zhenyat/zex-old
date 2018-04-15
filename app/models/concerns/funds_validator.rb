class FundsValidator < ActiveModel::Validator
  include AccountPro
  include DataPro

  # Run validation
  def validate record
    puts "ZZ! #{record.inspect}"
    if record.depo.present?
      data  = get_account_data
      pair  = record.pair
      names = pair.name.split('_')

      if record.kind == 'sell'                             # Validate base currency value
        base     = names.first
        ticker   = get_ticker pair.name
        base_max = record.depo / ticker.first.last['high'] # Maximum amount to be sold
        if base_max > data['funds'][base]
          record.errors[:base] << "Small #{base.upcase} balance: #{data['funds'][base]}. Needed: #{base_max.round(3)}"
        end
        
        if base_max < pair.min_amount
          record.errors[:base] << "#{base.upcase} amount is too small: #{base_max} < #{pair.min_amount}"
        end
      else                                                 # Validate quote currency value 
        quote = names.second
        if record.depo > data['funds'][quote]
          record.errors[:depo] << "small #{quote.upcase} balance: #{data['funds'][quote]}"
        end
      end
    end
  end
end
