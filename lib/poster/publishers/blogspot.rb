module Poster
  module Blogspot
    require 'shellwords'
    GOOGLE_LOGIN_URL = "https://accounts.google.com/ServiceLogin"
    GOOGLE_ACCOUNT = Shopelia::Application.config.flinker_google_account
    CASPER_SCRIPT_PATH = File.join(File.dirname(__FILE__), 'post_comment.js')
    
    def self.can_publish? page
      !!page.search("iframe#comment-editor")
    end
    
    def form
    end
    
    def fill form
    end
    
    def submit form
      comment = Shellwords.shellescape("#{@comment} #{@website_url}")
      url = Shellwords.shellescape(@url)
      command = "casperjs #{CASPER_SCRIPT_PATH} #{url} #{comment} #{GOOGLE_ACCOUNT[:email]} #{GOOGLE_ACCOUNT[:password]}"
      ret = %x{#{command}}
      !!(ret =~ /COMMENT HAS BEEN POSTED/)
    end
    
  end
end