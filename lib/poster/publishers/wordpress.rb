module Poster
  module Wordpress
    COMMENT_ACTION = /wp-comments-post/
    
    def fill form
      form['author'] = @author
      form['email'] = @email
      form['comment'] = @comment
      form['url'] = @website_url
      form
    end
    
    def submit form
      form.submit
    end
    
  end
end