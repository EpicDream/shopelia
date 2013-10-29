require 'uri'
require 'net/http'
require 'net/http/digest_auth'

class HttpDigestAuthRequest
  
  attr_reader :user, :password, :url
  
  def initialize user, password, url
    @user = user
    @password = password
    @url = url
    @digest_auth = Net::HTTP::DigestAuth.new
    @uri = uri()
    @http = http()
  end

  def get
    auth = get_auth_header
    request = Net::HTTP::Get.new @uri.request_uri
    request.add_field 'Authorization', auth
    response = @http.request request
    response_with_redirect(response)
  end
  
  private
  
  def response_with_redirect response
    case response
      when Net::HTTPRedirection 
        uri = URI.parse response['location']
        http = Net::HTTP.new uri.host, uri.port
        request = Net::HTTP::Get.new uri.request_uri
        response = http.request request
        response #TODO: do recursive call for multiple redirects
      else
       response
    end
  end
  
  def uri
    uri = URI.parse url
    uri.user = user
    uri.password = password
    uri
  end
  
  def http
    http = Net::HTTP.new @uri.host, @uri.port
    if @uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http
  end
  
  def get_auth_header
    request = Net::HTTP::Get.new @uri.request_uri
    response = @http.request request
    @digest_auth.auth_header @uri, response['www-authenticate'], 'GET'
  end
  
end
