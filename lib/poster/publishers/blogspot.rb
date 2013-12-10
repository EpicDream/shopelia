module Poster
  module Blogspot
    GOOGLE_LOGIN_URL = "https://accounts.google.com/ServiceLogin"
    COMMENT_ACTION = /comment-iframe/
    GOOGLE_ACCOUNT = Shopelia::Application.config.flinker_google_account
    
    def self.login agent
      page = agent.get(GOOGLE_LOGIN_URL)
      form = page.form_with(action: /ServiceLoginAuth/)
      form['Email'] = GOOGLE_ACCOUNT[:email]
      form['Passwd'] = GOOGLE_ACCOUNT[:password]
      form.submit
      agent
    end
    
    def self.page agent, url
      page = agent.get(url)
      link = page.search(".//a[@id='comment-editor-src']").first
      link and agent.get(link.attribute('href'))
    end
    
    def fill form
      form['commentBody'] = "#{@comment} - #{@website_url}"
      form
    end
    
    def submit form
      page = form.submit
    end
    
  end
end