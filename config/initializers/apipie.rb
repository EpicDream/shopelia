Apipie.configure do |config|
  config.app_name                = "Shopelia"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version         = "v1"
  config.validate                = false
end
