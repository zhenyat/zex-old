class FundsValidator < ActiveModel::Validator
  include AccountPro
  include DataPro

  def validate record
    
    ######################################################
    # Run values validation:
    #   depo value <= Quote balance
    #   Min. value for pair <= base value <= Base balance 
    ######################################################
    if record.class.name == 'Run'
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
      
    # Order values validation
    
    elsif record.class.name == 'Order'
      run   = record.run
      pair  = run.pair
      names = pair.name.split('_')

#      trans = record.rate * record.amount

    # FixOrder values validation
    else
      
    end 
  end
end
