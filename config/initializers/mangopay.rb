MangoPay.configure do |c|
  c.preproduction = !Rails.env.production?
  c.partner_id = Rails.env.production? ? 'shopelia' : 'prixing'
  c.key_path = Rails.env.production? ? "#{Rails.root}/keys/mango_pay/production" : "#{Rails.root}/keys/mango_pay/development"
  c.key_password = ''
end
