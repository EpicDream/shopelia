require "#{Rails.root}/lib/vulcain/vulcain"

Vulcain.configure do |c|
  c.api_key = "none"
  c.base_url = "https://vulcain.shopelia.fr:444"
end
