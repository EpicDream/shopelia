class AuthFailure < Devise::FailureApp

  def respond
    if request.content_type =~ /json/
      json_failure
    else
      super
    end
  end

  def json_failure
    self.status = :forbidden
    self.content_type = 'json'
    self.response_body = "{'error' : 'authentication error'}"
  end

end
