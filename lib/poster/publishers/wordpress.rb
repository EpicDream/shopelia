module Poster
  module Wordpress
    COMMENT_ACTION = /wp-comments-post/
    
    def self.can_publish?(page)
      !!self.form(page)
    end
    
    def self.form page=nil
      page ||= @page
      page.form_with(action:COMMENT_ACTION)
    end
    
    def fill form
      form['author'] = @author
      form['email'] = @email
      form['comment'] = token + @comment
      form['url'] = @website_url
      form
    end
    
    def submit form
      form.submit
      true
    end
    
    def token
      node = @page.search(".//form[@id='commentform']/noscript").first
      return "" unless node
      node.text =~ /comment:\s+(.*?)$/
      "#{$1} " 
    end
    
  end
end