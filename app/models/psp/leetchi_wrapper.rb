class Psp::LeetchiWrapper

  def initialize
    @errors = {}
  end

  def errors
    @errors
  end
  
  def remote_error object
    @errors = { :origin => "remote", 
                :message => object["TechnicalMessage"],
                :error_code => object["ErrorCode"],
                :user_message => object["UserMessage"],
                :type => object["Type"] }
  end
  
  def self.extract_errors object
    if m = object.errors.full_messages.join(",").match(/Error\: (.*)$/)
      eval(m[1])
    else
      nil
    end
  end
  
end

