json.extract! pair, :id, :base_id, :quote_id, :name, :code, :decimal_places, :min_price, :max_price, :min_amount, :hidden, :fee, :status, :created_at, :updated_at
json.url pair_url(pair, format: :json)
