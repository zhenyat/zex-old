class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :run, foreign_key: true
      t.decimal    :price,           precision: 15, scale: 5
      t.decimal    :amount,          precision: 15, scale: 8
      t.decimal    :wavg_price,      precision: 15, scale: 5
      t.decimal    :fix_price,       precision: 15, scale: 5
      t.decimal    :fix_amount,      precision: 15, scale: 8
      t.string     :error
      t.integer    :status,          null: false, default: 4, limit: 1  # default: created
      t.string     :x_id
      t.string     :x_pair
      t.integer    :x_type,                                   limit: 1
      t.decimal    :x_start_amount,  precision: 15, scale: 8
      t.decimal    :x_amount,        precision: 15, scale: 8
      t.decimal    :x_rate,          precision: 15, scale: 5
      t.integer    :x_timestamp
      t.integer    :x_status,        null: false, default: 4, limit: 1  # default: nil

      t.timestamps
    end
  end
end
