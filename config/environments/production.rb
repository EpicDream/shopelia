Shopelia::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.logger = Logger::Syslog.new("shopelia", Syslog::LOG_LOCAL5)

  # Code is not reloaded between requests
  config.cache_classes = true

  # Always use SSL
  config.force_ssl = false

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  config.assets.precompile += %w( developers/dashboard.js  developers/tracking.js )
  config.assets.precompile += %w( addresses.css application.css errors.css orders.css cart_items.css carts.css )
  config.assets.precompile += %w( admin/users.css admin/orders.css  admin/developers.css admin/incidents.css )
  config.assets.precompile += %w( admin/users.js  admin/orders.js   admin/developers.js  admin/incidents.js )
  config.assets.precompile += %w( admin/viking.css admin/dashboard.css admin/events.css admin/merchants.css )
  config.assets.precompile += %w( admin/viking.js  admin/dashboard.js  admin/events.js  admin/merchants.js  )
  config.assets.precompile += %w( admin/devices.css admin/collections.css )
  config.assets.precompile += %w( admin/devices.js  admin/collections.js )
  config.assets.precompile += %w( admin/georges/messages.js  admin/georges/devices.js  )
  config.assets.precompile += %w( admin/georges/messages.css admin/georges/devices.css )
  config.assets.precompile += %w( admin/blogs.js admin/blogs.css )
  config.assets.precompile += %w( admin/images.js admin/images.css )
  config.assets.precompile += %w( admin/comments.js admin/comments.css )
  config.assets.precompile += %w( admin/search/looks.css admin/search/looks.js )
  config.assets.precompile += %w( admin/themes.js admin/themes.css )
  config.assets.precompile += %w( admin/themes_previews.js admin/themes_previews.css )
  config.assets.precompile += %w( admin/csvs.js admin/csvs.css )
  config.assets.precompile += %w( admin/posts.js admin/posts.css )
  config.assets.precompile += %w( admin/looks.js admin/looks.css )
  config.assets.precompile += %w( admin/flinkers.js admin/flinkers.css )
  config.assets.precompile += %w( devise/passwords.css devise/sessions.css devise_override/sessions.css )
  config.assets.precompile += %w( devise/passwords.js  devise/sessions.js  devise_override/sessions.js  )
  config.assets.precompile += %w( devise_override/confirmations.css devise_override/registrations.css )
  config.assets.precompile += %w( devise_override/confirmations.js  devise_override/registrations.js  )
  config.assets.precompile += %w( devise_override/passwords.js devise_override/passwords.css  )
  config.assets.precompile += %w( home.js errors.js cart_items.js carts.js send_download_link.js )
  config.assets.precompile += %w( send_download_link.css html_app.js collections.js collections.css )
  config.assets.precompile += %w( admin/statistics.css admin/statistics.js )
  config.assets.precompile += %w( admin/newsletters.js admin/newsletters.css )
  config.assets.precompile += %w( admin/staff_picks.js admin/staff_picks.css )
  config.assets.precompile += %w( admin/flinker_merges.js admin/flinker_merges.css )
  config.assets.precompile += %w( flink/explore.js flink/explore.css )
  config.assets.precompile += %w( flink/home.js flink/home.css )
  config.assets.precompile += %w( flink/looks.js flink/looks.css )
  config.assets.precompile += %w( flink/application.js flink/application.css )
  config.assets.precompile += %w( flink/terms.js flink/terms.css )
  config.assets.precompile += %w( flink/contact.js flink/contact.css )
  config.assets.precompile += %w( admin/vendor_products.js admin/vendor_products.css )
  config.assets.precompile += %w( admin/pure_shopping_products.js admin/pure_shopping_products.css )
  
  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :redis_store, Shopelia::Application.config.redis_config

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
