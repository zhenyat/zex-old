class CreatePairs < ActiveRecord::Migration[5.2]
  def change
    create_table :pairs do |t|
      t.references :base#,  foreign_key: true
      t.references :quote#, foreign_key: true
      t.string     :name,           null: false
      t.string     :code,           null: false
      t.integer    :decimal_places
      t.decimal    :min_price,      precision: 10, scale: 5 
      t.integer    :max_price
      t.decimal    :min_amount,     precision: 10, scale: 5
      t.integer    :hidden,         limit: 1
      t.decimal    :fee,            precision:  5, scale: 2
      t.integer    :status,         null: false,   default: 0, limit: 1

      t.timestamps
    end
  end
end
