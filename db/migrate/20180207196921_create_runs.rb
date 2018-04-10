class CreateRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :runs do |t|
      t.references :pair,           foreign_key: true
      t.integer    :kind,           null: false, default: 0,    limit: 1
      t.decimal    :depo,           null: false, precision: 15, scale: 5
      t.decimal    :last,           null: false, precision: 15, scale: 5
      t.float      :indent,         null: false, default: 10.0
      t.float      :overlap,        null: false, default: 10.0
      t.float      :martingale,     null: false, default: 15.0
      t.integer    :orders_number,  null: false, default: 10
      t.float      :profit,         null: false, default: 1.0
      t.integer    :scale,          null: false, default: 1,    limit: 1
      t.decimal    :stop_loss,      null: false, precision: 15, scale: 5
      t.integer    :status,         null: false, default: 0,    limit: 1

      t.timestamps
    end
  end
end
