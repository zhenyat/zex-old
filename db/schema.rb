# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_02_16_112550) do

  create_table "coins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "run_id"
    t.integer "ex_id"
    t.decimal "price", precision: 15, scale: 5
    t.decimal "amount", precision: 15, scale: 8
    t.decimal "wavg_price", precision: 15, scale: 5
    t.string "fix_price"
    t.decimal "fix_amount", precision: 15, scale: 8
    t.string "error"
    t.integer "status", limit: 1, default: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_orders_on_run_id"
  end

  create_table "pairs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "base_id"
    t.bigint "quote_id"
    t.string "name", null: false
    t.string "code", null: false
    t.integer "decimal_places"
    t.decimal "min_price", precision: 10, scale: 5
    t.integer "max_price"
    t.decimal "min_amount", precision: 10, scale: 5
    t.integer "hidden", limit: 1
    t.decimal "fee", precision: 5, scale: 2
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_id"], name: "index_pairs_on_base_id"
    t.index ["quote_id"], name: "index_pairs_on_quote_id"
  end

  create_table "runs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "pair_id"
    t.integer "kind", limit: 1, default: 0, null: false
    t.decimal "depo", precision: 15, scale: 5, null: false
    t.decimal "last", precision: 15, scale: 5, null: false
    t.float "indent", default: 5.0, null: false
    t.float "overlay", default: 10.0, null: false
    t.float "martingale", default: 15.0, null: false
    t.integer "orders_number", default: 6, null: false
    t.float "profit", default: 2.0, null: false
    t.integer "scale", limit: 1, default: 0, null: false
    t.decimal "stop_loss", precision: 15, scale: 5, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pair_id"], name: "index_runs_on_pair_id"
  end

  create_table "trades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "pair_id"
    t.integer "kind", limit: 1
    t.decimal "price", precision: 15, scale: 5
    t.decimal "amount", precision: 15, scale: 8
    t.integer "tid"
    t.integer "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pair_id"], name: "index_trades_on_pair_id"
  end

  add_foreign_key "orders", "runs"
  add_foreign_key "runs", "pairs"
  add_foreign_key "trades", "pairs"
end
