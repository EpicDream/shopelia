$crypto = nil
$gpgme_passphrase = nil

def passfunc(obj, uid_hint, passphrase_info, prev_was_bad, fd)
  raise ArgumentError, "No GPG passphrase available" if $gpgme_passphrase.nil?
  system('stty -echo')
  io = IO.for_fd(fd, 'w')
  io.puts($gpgme_passphrase)
  io.flush
  $stderr.puts
  system('stty echo')
end

GPGME::Engine.home_dir = "#{Rails.root}/gpg"

if Rails.env.production?
  $crypto = GPGME::Crypto.new(:passphrase_callback => method(:passfunc))
else 
  $crypto = GPGME::Crypto.new
end

# $crypto.decrypt($crypto.encrypt('hello', :recipients => 'gpg-production@shopelia.com'))

