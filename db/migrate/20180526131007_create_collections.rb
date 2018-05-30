class CreateCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :collections do |t|
      t.references :pair, foreign_key: true
      t.integer :slot,    null: false
      t.integer :status,  null: false, default: 0, limit: 1

      t.timestamps
    end
    add_index :collections, [:pair_id, :slot], unique: true
  end
end
