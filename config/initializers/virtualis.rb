require "#{Rails.root}/lib/virtualis/virtualis"

Virtualis.configure do |c|
  if Rails.env.production?
    c.endpoint_url  = 'https://rec-www.service-virtualis.com/wspart/services/VirtualisService'
    c.messages_path = "#{Rails.root}/lib/virtualis/messages/"
    c.certificate   = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/keys/virtualis/dev_cert.pem")
    c.key           = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/keys/virtualis/dev_key.pem"))
    c.logger        = Logger.new("#{Rails.root}/log/virtualis-production.log")
    c.efs           = '02'
    c.identifiant   = '54408787'
    c.contrat       = 'CA20270339'
  else
    c.endpoint_url  = 'https://rec-www.service-virtualis.com/wspart/services/VirtualisService'
    c.messages_path = "#{Rails.root}/lib/virtualis/messages/"
    c.certificate   = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/keys/virtualis/dev_cert.pem")
    c.key           = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/keys/virtualis/dev_key.pem"))
    c.logger        = Logger.new("#{Rails.root}/log/virtualis-development.log")
    c.efs           = '02'
    c.identifiant   = '54408787'
    c.contrat       = 'CA20270339'
  end
end

