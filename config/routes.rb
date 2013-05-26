require 'api_constraints'

Shopelia::Application.routes.draw do
  apipie

  devise_for :users

  get "home/index"

  root :to => "home#index"
  
  namespace :api do
    scope :module => :v1, constraints: ApiConstraints.new(version:1, default:true)  do
      devise_for :users
      resources :addresses, :only => [:index, :create, :show, :update, :destroy]
      resources :payment_cards, :only => [:index, :create, :show, :destroy]
      resources :phones, :only => [:index, :create, :show, :update, :destroy] do
        resources :lookup, :only => :index, :controller => "phones/lookup"
      end
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
      namespace :places do
        resources :autocomplete, :only => :index
        resources :details, :only => :show
      end      
    end
  end
  
end
