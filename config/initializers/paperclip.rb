Paperclip::Attachment.default_options[:use_timestamp] = false

Paperclip.interpolates :fmd5 do |attachment, style| 
  attachment.fingerprint[0..2]
end

Paperclip.interpolates :md5 do |attachment, style| 
  attachment.fingerprint
end