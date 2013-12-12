module Poster
  module Blogspot
    GOOGLE_LOGIN_URL = "https://accounts.google.com/ServiceLogin"
    COMMENT_ACTION = /comment-iframe|comment\.do/
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
      link ||= page.search(".//div[@id='comments']//a[contains(@href, 'blogger.com/comment')]").first
      link and agent.get(link.attribute('href'))
    end
    
    def fill form
      comment = "#{@comment} - #{@website_url}"
      form['commentBody'] = comment if form.has_field?('commentBody')
      form['postBody'] = comment if form.has_field?('postBody')
      form['identityMenu'] = "GOOGLE"
      form
    end
    
    def submit form
      page = form.submit
      puts page.uri.to_s
      true
      # page.uri.to_s !~ /comment-iframe/
    end
    
  end
end