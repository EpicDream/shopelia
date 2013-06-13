require 'api_constraints'

Shopelia::Application.routes.draw do
  apipie

  devise_for :users, controllers: { confirmations: 'devise_override/confirmations' }
  devise_scope :user do
    put "/confirm" => "devise_override/confirmations#confirm"
  end

  resources :contact, :only => :create
  resources :orders, :only => [:show, :update]

  namespace :admin do
    resources :orders, :only => [:index, :show, :update]
    resources :users, :only => [:index, :show, :destroy]
  end

  namespace :api do
    scope :module => :v1, constraints: ApiConstraints.new(version:1, default:true)  do
      devise_for :users
      resources :addresses, :only => [:index, :create, :show, :update, :destroy]
      resources :payment_cards, :only => [:index, :create, :show, :destroy]
      resources :phone_lookup, :only => :show
      resources :merchants, :only => [:index, :create]
      resources :orders, :only => [:create, :show]
      resources :users, :only => [:show, :update, :destroy]
      namespace :users do
        resources :autocomplete, :only => :create
        resources :exists, :only => :create
        resources :reset, :only => :create
        resources :verify, :only => :create
      end
      namespace :callback do
        resources :orders, :only => :update
      end
      namespace :limonetik do
        resources :orders, :only => :update
      end
      namespace :places do
        resources :autocomplete, :only => :index
        resources :details, :only => :show
      end
    end
  end

  match '*not_found', to: 'errors#error_404'
  get "errors/error_404"
  get "errors/error_500"
end
