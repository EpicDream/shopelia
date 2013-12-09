require_relative 'publishers/wordpress'

module Poster
  PUBLISHERS = [Wordpress]
  
  class Comment
    attr_accessor :comment, :url, :email, :author, :form, :website_url
    
    def initialize comment, author, email, website_url=nil, post_url=nil
      @comment = comment
      @url = post_url
      @email = email
      @agent = Mechanize.new
      @author = author
      @website_url = website_url
      @agent.user_agent_alias = 'Mac Safari'
      @publisher = publisher()
    end
    
    def deliver comment=nil
      return unless @publisher
      @comment = comment if comment
      fill @form
      @form.submit
      true
    rescue => e
      report_incident("Submit form failure")
      false
    end
    
    def url=url
      @url = url
      @publisher = publisher()
    end
    
    def publisher
      return unless @url
      @page = @agent.get(@url)
      forms = @page.forms
      PUBLISHERS.each { |publisher|
        if @form = forms.detect { |form| form.action =~ publisher::COMMENT_ACTION }
          extend publisher
          return publisher
        end
      }
      report_incident("Publisher missing")
      nil
    end
    
    private
    
    def report_incident description=nil
      Incident.create(
      :issue => "Poster::Comment", 
      :severity => Incident::IMPORTANT, 
      :description => "#{description} - #{@url}")
    end
    
  end
  
  
end