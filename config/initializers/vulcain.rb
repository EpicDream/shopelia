require "#{Rails.root}/lib/vulcain/vulcain"

Vulcain.configure do |c|
  c.api_key = "none"
  c.base_url = "http://127.0.0.1:3000" # "http://vulcain.shopelia.fr:3000"
end
