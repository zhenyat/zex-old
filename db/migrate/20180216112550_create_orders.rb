class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :run, foreign_key: true
      t.decimal :price,       precision: 15, scale: 5
      t.decimal :amount,      precision: 15, scale: 8
      t.decimal :wavg_price,  precision: 15, scale: 5
      t.string :fix_price,    precision: 15, scale: 5
      t.integer :status,      null: false,   default: 0, limit: 1

      t.timestamps
    end
  end
end
