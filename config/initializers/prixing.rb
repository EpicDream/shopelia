require "#{Rails.root}/lib/prixing/prixing"

Prixing.configure do |c|
  c.device = "shopelia"
  c.base_url = "http://api.prixing.fr"
end
