require 'api_constraints'

Shopelia::Application.routes.draw do
  apipie

  devise_for :users

  get "home/index"

  root :to => "home#index"
  
  namespace :api do
    scope :module => :v1, constraints: ApiConstraints.new(version: 1, default: :true)  do
      devise_for :users
      resources :addresses, :only => [:index, :create, :show, :update, :destroy]
      resources :phones, :only => [:index, :create, :show, :update, :destroy]
      resources :users, :only => [:show, :update, :destroy]
    end
  end
  
end
