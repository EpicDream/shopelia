class Psp::LeetchiWrapper

  def initialize
    @psp = Psp.find_by_name(Psp::LEETCHI)
    @errors = {}
  end

  def errors
    @errors
  end
  
  def local_error object
     @errors = { :origin => "local", 
                 :message => object.errors.full_messages.join(",") }.to_json
  end
  
  def remote_error object
    @errors = { :origin => "remote", 
                :message => object["TechnicalMessage"],
                :error_code => object["ErrorCode"],
                :user_message => object["UserMessage"],
                :type => object["Type"] }.to_json
  end
  
  def self.extract_errors object
    if m = object.errors.full_messages.join(",").match(/Error\: (.*)$/)
      JSON.parse m[1]
    else
      nil
    end
  end
  
end

