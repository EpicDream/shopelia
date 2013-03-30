Leetchi.configure do |c|
  c.preproduction = !Rails.env.production?
  c.partner_id = 'example'
  c.key_path = "#{Rails.root}/keys/example.pem"
  c.key_password = ''
end
