class CreateCoins < ActiveRecord::Migration[5.2]
  def change
    create_table :coins do |t|
      t.string  :name,   null: false
      t.string  :code,   null: false
      t.integer :status, null: false, default: 0, limit: 1

      t.timestamps
    end
  end
end
