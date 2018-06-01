Rails.application.routes.draw do
  get  'selections/new'
  post 'selections/charts'
  
  get  'trades/candlesticks'
  get  'trades/create_cash'
  get  'trades/index'
  get  'trades/order_book'
  get  'trades/tick_charts'
  get  'trades/update_cash'
  
  get  'candles/add'
  get  'candles/index'
  
  resources :runs do
    get :cancel,            on: :member
    get :check_orders,      on: :member
    get :place_orders,      on: :member
    
    get :cancel_fix_order,  on: :member
    get :check_fix_orders,  on: :member
    get :place_fix_order,   on: :member
    get :update_fix_orders, on: :member
  end
  
  resources :pairs
  resources :coins
  
  root 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
