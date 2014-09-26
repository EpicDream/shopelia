require File.expand_path('../boot', __FILE__)
require 'rails/all'
require File.join(File.dirname(__FILE__), '../lib/core_extensions')

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module Shopelia
  class Application < Rails::Application
  
    # Base host
    config.host = 'http://www.flink.io'
    config.image_host = 'http://www.flink.io'
    config.avatar_host = 'http://www.flink.io' #cause, need another base url for avatars in dev.
    config.deeplink_host = 'flink.io'

    # Social config
    config.facebook_app_id = '735090113186174'
    config.appstore_app_id = '798552697'
    
    # Maximum number of times the order is allowed to retry a new account creation
    config.max_retry = 3
    
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/merchants #{config.root}/app/models/activities)
    config.action_mailer.default_url_options = { :host => 'lipstick.flink.io', :protocol => 'https' }
    config.action_mailer.asset_host = "http://www.flink.io"

    WillPaginate.per_page = 20

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Paris'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :pincode, :number, :cvv]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Compile assets
    config.assets.compile = true

    # Redis
    config.redis_config = {
      :host => '127.0.0.1',
      :port => 6379,
      :timeout => 20
    }

    # # Pusher App
    # Pusher.url = "http://654ffe989dceb4af5e03:cd54721d7ae7b6fbff42@api.pusherapp.com/apps/54299"

    # Mailjet
    config.action_mailer.delivery_method = :mailjet

    # GCM
    # GCM.host = 'https://android.googleapis.com/gcm/send'
    # GCM.format = :json
    # GCM.key = "AIzaSyDGlTm2cS2g1QA7IrsLyL7l63BxioIsJpE"

    # APNS
    config.apns = {
        development: {
            host: 'gateway.sandbox.push.apple.com',
            pem: "#{Rails.root}/keys/apple/development.pem",
            port: 2195,
            pass: ""
        },
        beta: {
           host: 'gateway.push.apple.com',
           pem: "#{Rails.root}/keys/apple/beta.pem",
           port: 2195,
           pass: ""
        },                
        production: {
            host: 'gateway.push.apple.com',
            pem: "#{Rails.root}/keys/apple/production.pem",
            port: 2195,
            pass: ""
        },
    }

    # Flink google account to post comments on blogspot sites
    config.flinker_google_account = {email:"flinkhq@gmail.com", password:"ShopeliaRocks1"}
    
    config.to_prepare do
      Devise::PasswordsController.layout "flink"
    end
    
    config.min_date = Date.parse("2014-01-01").to_time
    
    config.emails_for_testing = ["olivierfisch@hotmail.com", "anoiaque@gmail.com", "nicolasbigot@icloud.com"]
  end
  
end
