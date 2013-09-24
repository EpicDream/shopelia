require 'selenium-webdriver'
require 'headless'

module PaylineDriver

  def self.inject card, url
    
    @url = url
    Headless.ly do
      @driver = Selenium::WebDriver.for :chrome
      @driver.get @url
      
      fill 'number', card[:number]
      fill 'expirationDate_month', card[:exp_month]
      fill 'expirationDate_year', card[:exp_year]
      fill 'cvv', card[:cvv]
      click 'paybutton'

      begin
        wait = Selenium::WebDriver::Wait.new(:timeout => 15)
        wait.until { @driver.current_url =~ /shopelia/  }
      rescue 
        @driver.quit
        raise DriverError.new("Time out on card validation for #{@url}")
      end

      @driver.quit
    end
  end

  private

  def self.fill ref, content
    get(ref).send_keys(content)
  end
  
  def self.click ref
    get(ref).click
  end

  def self.get ref
    begin
      @driver.find_element :name => ref
    rescue
      begin
        @driver.find_element :id => ref
      rescue
        raise DriverError.new("Missing element #{ref} for #{@url}")
      end
    end
  end

  class DriverError < RuntimeError
    attr :error
    def initialize error
      @error = error
    end
  end  
end

