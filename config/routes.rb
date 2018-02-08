Rails.application.routes.draw do
  get 'trades/candlesticks'
  get 'trades/create_cash'
  get 'trades/index'
  get 'trades/order_book'
  get 'trades/update_cash'
  resources :runs
  resources :pairs
  resources :coins
  root 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
