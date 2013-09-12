require 'api_constraints'

Shopelia::Application.routes.draw do

  match "/checkout", :controller => "html_app", :action => "index"

  apipie

  devise_for :users, controllers: { 
    confirmations: 'devise_override/confirmations',
    registrations: 'devise_override/registrations',
    sessions: 'devise_override/sessions',    
  }
  devise_scope :user do
    put "/confirm" => "devise_override/confirmations#confirm"
  end

  resources :home, :only => :index
  resources :contact, :only => :create
  resources :gateway, :only => :index
  
  resources :addresses
  resources :cart_items, :only => :show do
    get :unsubscribe, :on => :member
  end
  resources :orders, :only => [:show, :update] do
    get :confirm, :on => :member
    get :cancel, :on => :member
  end
  resources :payment_cards

  namespace :admin do
    match "/", to: "dashboard#index"
    resources :dashboard, :only => :index
    resources :developers, :only => [:index, :new, :create]
    resources :events, :only => :index
    resources :incidents, :only => [:index, :update]
    resources :merchants, :only => [:index, :show, :new, :create, :update]
    resources :orders, :only => [:index, :show, :update]
    resources :users, :only => [:index, :show, :destroy]
    resources :viking, :only => :index
    resources :products do
      get :retry, :on => :member
      get :mute, :on => :member
    end
  end
  
  namespace :zen do
    resources :orders, :only => [:show, :update] do
      get :confirm, :on => :member
      get :cancel, :on => :member
    end
  end

  namespace :api do
    scope :module => :v2, constraints: ApiConstraints.new(version:2)  do
      namespace :users do
        resources :verify, :only => :create
      end
    end
    scope :module => :v1, constraints: ApiConstraints.new(version:1, default:true)  do
      devise_for :users
      resources :addresses, :only => [:index, :create, :show, :update, :destroy]
      resources :cart_items, :only => :create
      resources :events, :only => [:index, :create]
      resources :payment_cards, :only => [:index, :create, :show, :destroy]
      resources :phone_lookup, :only => :show
      resources :merchants, :only => [:index, :create]
      resources :orders, :only => [:create, :show]
      resources :products, :only => [:index, :create]
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
      namespace :mango_pay do
        resources :notifications, :only => :index
      end      
      namespace :limonetik do
        resources :orders, :only => :update
      end
      namespace :places do
        resources :autocomplete, :only => :index
        resources :details, :only => :show
      end
    end
    namespace :showcase do
      namespace :products do
        resources :search, :only => :index
      end
    end
    namespace :viking do
      resources :products, :only => [:index, :update]
      namespace :products do
        get :shift
        get :failure
        get :failure_shift
        get :alive
      end
      resources :merchants, :only => [:show, :update, :index]
    end
    namespace :vulcain do
      resources :merchants, :only => :update
    end
  end

  match "about" => "home#about"


  match '*not_found', to: 'errors#error_404'
  get "errors/error_404"
  get "errors/error_500"
  root to: 'home#index'

end
