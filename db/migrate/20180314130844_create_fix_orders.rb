class CreateFixOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :fix_orders do |t|
      t.references :run, foreign_key: true
      t.decimal    :price,           precision: 15, scale: 5
      t.decimal    :amount,          precision: 15, scale: 8
      t.string     :error
      t.integer    :status,          null: false, default: 4, limit: 1  # default: created
      t.string     :x_id
      t.string     :x_pair
      t.integer    :x_type,                                   limit: 1
      t.decimal    :x_done_amount,   precision: 15, scale: 8
      t.decimal    :x_rest_amount,   precision: 15, scale: 8
      t.decimal    :x_rate,          precision: 15, scale: 5
      t.integer    :x_timestamp
      t.decimal    :x_base,          precision: 15, scale: 8
      t.decimal    :x_quote,         precision: 15, scale: 5
      t.integer    :x_status,                                  limit: 1

      t.timestamps
    end
  end
end
