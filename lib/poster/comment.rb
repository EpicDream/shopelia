require 'pathname'

module Poster
  class Comment
    
    attr_accessor :comment, :url, :email, :author, :form, :website_url
    
    def initialize args={}
      @comment = args[:comment]
      @url = args[:post_url]
      @email = args[:email]
      @author = args[:author]
      @website_url = args[:website_url]
      
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'
      @publisher = publisher()
    end
    
    def deliver comment=nil
      return unless @publisher
      @comment = comment if comment
      @form = fill @form
      submit @form
      true
    rescue => e
      report_incident("Submit form failure", e)
      false
    end
    
    def url=url
      @url = url
      @publisher = publisher()
    end
    
    def publisher
      return @publisher if @publisher
      return unless @url
      @page = @agent.get(@url)
      
      PUBLISHERS.each { |publisher|
        if publisher.respond_to?(:page)
          page = publisher.page(@agent, @url)
          next unless page
          @page = page
        end
        if publisher.respond_to?(:login)
          @agent = publisher.login(@agent) 
          @page = @agent.get(@page.uri) #reload after login
        end
        
        if @form = @page.form_with(action: publisher::COMMENT_ACTION )
          extend publisher
          @publisher = publisher
          break
        end
      }
      report_incident("Publisher missing") unless @publisher
      @publisher
    rescue
      report_incident("Publisher missing")
    end
    
    private
    
    def report_incident description=nil, e=nil
      Rails.logger.error("Poster::Comment\n#{e}\n#{e.backtrace.join("\n")}") if e
      Incident.create(
      :issue => "Poster::Comment", 
      :severity => Incident::IMPORTANT, 
      :description => "#{description} - #{@url}")
    end
    
  end
  
  def self.publishers
    Dir.glob(File.join(File.dirname(__FILE__), 'publishers/*.rb')).map { |path|
      require path  
      path = Pathname.new(path)
      klass_name = "Poster::#{path.basename.to_s[0..-4].camelize}"
      klass_name.constantize
    }
  end
  
  PUBLISHERS = Poster.publishers
end