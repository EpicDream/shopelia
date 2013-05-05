require "#{Rails.root}/lib/vulcain/vulcain"

Vulcain.configure do |c|
  c.api_key = "none"
  c.base_url = "http://vulcain.shopelia.fr:3000"
end
