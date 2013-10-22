require File.expand_path('../boot', __FILE__)

require 'rails/all'
require File.join(File.dirname(__FILE__), '../lib/core_extensions')

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Shopelia
  class Application < Rails::Application
  
    # Base host
    config.host = 'https://www.shopelia.fr'

    # Maximum number of times the order is allowed to retry a new account creation
    config.max_retry = 3
  
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/merchants)
    
    config.action_mailer.default_url_options = { :host => 'www.shopelia.fr', :protocol => 'https' }
    config.action_mailer.asset_host = "http://www.shopelia.fr"

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
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :fr

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

    config.redis_config = {
      :host => '127.0.0.1',
      :port => 6379,
      :timeout => 20
    }

    # Pusher App
    Pusher.url = "http://654ffe989dceb4af5e03:cd54721d7ae7b6fbff42@api.pusherapp.com/apps/54299"

    config.action_mailer.delivery_method = :mailjet


  end
end
