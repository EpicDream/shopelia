require 'api_constraints'

Shopelia::Application.routes.draw do
  apipie

  devise_for :users

  get "home/index"

  root :to => "home#index"
  
  namespace :api do
    scope :module => :v1, constraints: ApiConstraints.new(version: 1, default: :true)  do
      resources :users, :except => [:new, :edit, :index]
    end
  end
  
end
