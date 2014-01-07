require 'pathname'

module Poster
  class Comment
    
    attr_accessor :comment, :post_url, :email, :author, :form, :website_url
    
    def initialize args={}
      @comment = args[:comment]
      @post_url = args[:post_url]
      @email = args[:email]
      @author = args[:author]
      @website_url = args[:website_url]
      
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'
      @agent.keep_alive = true
      @agent.redirect_ok = :all
      @agent.follow_meta_refresh = :anywhere
      
      @publisher = publisher()
    end
    
    def deliver comment=nil
      return unless @publisher
      @comment = comment if comment
      @form = fill @form
      submit @form
    rescue => e
      report_incident("Submit form failure", e)
      false
    end
    
    def post_url=url
      @post_url = url
      @publisher = publisher()
    end
    
    def publisher
      return @publisher if @publisher
      return unless @post_url
      @page = @agent.get(@post_url)
      PUBLISHERS.each { |publisher|
        if publisher.can_publish?(@page)
          extend publisher
          @form = publisher.form(@page)
          @publisher = publisher
          break
        end
      }
      @publisher
    rescue => e
      report_incident("Exception while searching publisher", e)
    end
    
    private
    
    def report_incident description=nil, e=nil
      Incident.create(
      :issue => "Poster::Comment", 
      :severity => Incident::IMPORTANT, 
      :description => "#{description} - #{@post_url}")
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