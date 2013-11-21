require "#{Rails.root}/lib/virtualis/virtualis"

Virtualis.configure do |c|
  if Rails.env.production?
    c.endpoint_url  = 'https://www.service-virtualis.com/wspart/services/VirtualisService'
    c.messages_path = "#{Rails.root}/lib/virtualis/messages/"
    c.certificate   = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/keys/virtualis/prod.crt.pem")
    if $gpgme_passphrase.present?
      c.key           = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/keys/virtualis/prod.key.pem"), $gpgme_passphrase)
    end
    c.logger        = Logger.new("#{Rails.root}/log/virtualis-production.log")
    c.efs           = '13'
    c.identifiant   = '18255530'
    c.contrat       = 'TE71340861'
    c.add_timestamp = true
  else
    c.endpoint_url  = 'https://rec-www.service-virtualis.com/wspart/services/VirtualisService'
    c.messages_path = "#{Rails.root}/lib/virtualis/messages/"
    c.certificate   = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/keys/virtualis/dev_cert.pem")
    c.key           = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/keys/virtualis/dev_key.pem"))
    c.logger        = Logger.new("#{Rails.root}/log/virtualis-development.log")
    c.efs           = '02'
    c.identifiant   = '54408787'
    c.contrat       = 'CA20270339'
    c.add_timestamp = false  
  end
end

