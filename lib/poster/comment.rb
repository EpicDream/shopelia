require_relative 'publishers/wordpress'

module Poster
  PUBLISHERS = {
    /wp-comments-post/ => Wordpress
  }
  
  class Comment
    attr_accessor :message, :url, :email
    
    def initialize message, url=nil, email=nil
      @message = message
      @url = url
      @email = email
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'
      @publisher = publisher()
      extend @publisher if @publisher
    end
    
    def deliver
      return unless @publisher
      true
    end
    
    def url=url
      @url = url
      @publisher = publisher()
      extend @publisher if @publisher
    end
    
    def publisher
      return unless @url
      @page = @agent.get(@url)
      forms = @page.forms
      PUBLISHERS.each { |pattern, publisher|
        return publisher if forms.any? { |form| form.action =~ pattern }
      }
      report_incident
      nil
    end
    
    private
    
    def report_incident
      Incident.create(:issue => "Poster::Comment", :severity => Incident::IMPORTANT, :description => "url : #{@url}")
    end
    
  end
  
  
end