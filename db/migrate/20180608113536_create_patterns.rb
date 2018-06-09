class CreatePatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :patterns do |t|
      t.string   :name,       null: false
      t.string   :title,      null: false
      t.integer  :mix,        null: false, default: 0, limit: 1
      t.text     :description
      t.string   :icon
      t.integer  :status,     null: false, default: 0, limit: 1

      t.timestamps
    end
    add_index :patterns, :name, unique: true
  end
end
