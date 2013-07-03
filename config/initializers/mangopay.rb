MangoPay.configure do |c|
  c.preproduction = !Rails.env.production?
  c.partner_id = 'prixing'
  c.key_path = "#{Rails.root}/keys/development_rsa"
  c.key_password = ''
end
