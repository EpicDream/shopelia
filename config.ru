# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'sidekiq/web'

run Rack::URLMap.new(
    "/" => Shopelia::Application,
    "/sidekiq" => Sidekiq::Web
)

