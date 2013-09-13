module Virtualis
  class Request
    
    attr_reader :response
    
    def initialize
      @http = initialized_http_client 
      @headers = {"Content-Type"=>"text/xml;charset=UTF-8"}
    end
    
    def send message
      signed_message = sign(message)
      Virtualis.configuration.logger.info("########### #{Time.now} MESSAGE ###################\n#{signed_message}\n\n")
      response_message = @http.request(:post, Virtualis.configuration.endpoint_url, nil, signed_message, @headers)
      @response = response_message.content
      Virtualis.configuration.logger.info("########### #{Time.now} RESULT ###################\n#{@response}\n\n")
      @response
    end
    
    private
    
    def sign xml
      signer = VSigner.new(xml)
      signer.cert = Virtualis.configuration.certificate
      signer.private_key = Virtualis.configuration.key
      signer.security_token_id = SecureRandom.uuid
      node = signer.document.xpath("//soap:Body").first
      signer.digest! node, {id:SecureRandom.uuid}
      signer.sign!
      signer.to_xml
    end
    
    def initialized_http_client
      client = ::HTTPClient.new
      client.ssl_config.cert_store.set_default_paths
      client.ssl_config.client_cert = Virtualis.configuration.certificate
      client.ssl_config.client_key = Virtualis.configuration.key
      client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      client
    end
    
  end
end
