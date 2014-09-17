Shopelia::Application.routes.draw do

  get "/flinkers/:id", to: redirect('/')
  get "/themes/:id", to: redirect('/')
  get "/themes", to: redirect('/')
  get "/hashtags", to: redirect('/')
  get "/hashtags/:id", to: redirect('/')
  
  get "comments/index"
  get "comments/create"

  apipie

  devise_for :developers
  devise_for :flinkers
  devise_for :users, controllers: { 
    confirmations: 'devise_override/confirmations',
    passwords: 'devise_override/passwords',
    registrations: 'devise_override/registrations',
    sessions: 'devise_override/sessions', 
  }

  namespace :admin do
    match "/", to: "posts#index"
    resources :collections do
      get :up, :on => :member
      get :down, :on => :member
    end
    resources :collection_items
    resources :dashboard, :only => :index
    resources :developers, :only => [:index, :new, :create]
    resources :devices, :only => :show
    resources :events, :only => :index
    resources :incidents, :only => [:index, :update]
    resources :merchants, :only => [:index, :show, :edit, :update]
    resources :orders, :only => [:index, :show, :update]
    resources :users, :only => [:index, :show, :destroy]
    resources :viking, :only => :index
    resources :blogs
    resources :comments, :only => [:index, :show] do
      post :reply
    end
    resources :posts
    resources :images, :only => [:show, :update]
    resources :flinkers
    resources :statistics, only:[:index]
    resources :csvs, only:[:index, :show]
    resources :themes do
      resources :looks, only:[:index, :create, :destroy], controller:'themes/looks'
      resources :look_images, only:[:index], controller:'themes/look_images'
      resources :flinkers, only:[:index, :create, :destroy], controller:'themes/flinkers'
    end
    resource :themes_preview, only: :show
    resources :looks do
      get :publish, :on => :member
      get :reject, :on => :member
      get :reject_quality, :on => :member
      get :prepublish, :on => :member
      put :reinitialize_images, :on => :member
      put :highlight_with_tag, :on => :member
      post :add_hashtags_from_staff_hashtags, :on => :member
    end
    namespace :search do
      resources :looks, only:[:index]#, controller:'search/looks'
    end
    resources :look_images
    resources :look_products
    resources :products do
      get :retry, :on => :member
      get :mute, :on => :member
    end
    resources :newsletters do
      get :test
      get :send_to_subscribers
    end
    resources :staff_picks
    resources :flinker_merges, only: [:new, :show, :create]
    resources :pure_shopping_products, only: [:index, :create]
    resources :vendor_products, only: [:index, :destroy, :update]
    resources :apns_notifications, only: [:new, :create, :show, :update] do
      get :test
      get :send_to_flinkers
    end
    resources :in_app_notifications, only: [:new, :create, :show, :update]
    resources :staff_hashtags
    resources :publications, only: [:index]
  end

  namespace :api do
    namespace :flink do
      devise_for :flinkers
      resources :flinkers, :only => :index
      resources :flinkers_search, :only => :index
      resources :publishers, :only => :index
      resources :staff_picks, :only => :index
      resources :activities, :only => :index
      resources :facebook_friends, :only => :index
      resources :instagram_friends, :only => :index
      resources :twitter_friends, :only => :index
      resources :top_flinkers, :only => :index
      resources :avatars, :only => :create
      resources :follows, :only => [:index, :create, :destroy]
      resources :followings, :only => [:index, :create, :destroy]
      resources :followers, :only => :index
      resources :popular_looks, :only => :index
      resources :recent_looks, :only => :index
      resources :best_looks, :only => :index
      resources :trend_setters, :only => :index
      resources :private_messages, :only => :create
      resources :looks, :only => :index do
        resources :comments, :only => [:index, :create], :controller => "looks/comments"
        resources :sharings, :only => :create, :controller => "looks/sharings"
        resources :likes, :only => :create, :controller => "looks/likes"
        resources :products, :only => :index, :controller => "looks/products"
        delete "likes" => "looks/likes#destroy"
      end
      namespace :likes do
        resources :looks, only: :index
      end
      namespace :refresh do
        resources :looks, only: :index
        resources :likes, only: :index
        resources :followings, only: :index
      end
      namespace :connect do
        resources :instagram, only: :create
        resources :twitter, only: :create
      end
      namespace :followings do
        resources :looks, only: :index
        resources :updated_looks, only: :index
      end
      namespace :flinkers do
        resources :looks, only: :index
        resources :passwords, only: :create
      end
      namespace :hashtags do
        resources :looks, only: :index
      end
      namespace :mailjet do
        resources :unsubscribes, only: :create
      end
      
      resources :themes, :only => [:index, :show]
      get 'followers_count' => "followers#count"
      
      scope '/ws' do
        get 'flinkers' => "web_services/flinkers#show"
      end
      namespace :analytics do
        resources :events, only: [:create]
        resources :publishers, only: [:show]
        resources :looks, only: [:show]
      end
      resources :in_app_notifications, only: :index
    end
  end

  put "api/flink/flinkers/session_touch", to: "api/flink/sessions#update"

  # Flink web site
  root to: 'flink/home#index'
  get "terms", to: "flink/terms#index"
  get "contact", to: "flink/contact#index"
  get "explore", to: "flink/explore#show", as: :flink_explore
  get "explore/:category", to: "flink/explore#show"
  get "looks/:id", to: "flink/looks#show", as: :flink_looks
  
  match '*unmatched_route', :to => 'application#raise_not_found!'
end
