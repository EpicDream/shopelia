require 'php_serialize'

module Customers
  class Merkav

    API_HOST = "api1.merkavonline.com"
    WSDL_URL = "https://#{API_HOST}/index.php?module=wsdl"
    API_KEY = "81_2237fa2e69503f1eb1de18dfd85c9fa1606bcdca"

    NAMESPACES = { 
      'xmlns:SOAP-ENV' => "http://schemas.xmlsoap.org/soap/envelope/",
      'xmlns:ns1' => "urn:xmethods-delayed-quotes",
      'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema",
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'xmlns:ns2' => "http://xml.apache.org/xml-soap",
      'xmlns:SOAP-ENC' => "http://schemas.xmlsoap.org/soap/encoding/",
      'SOAP-ENV:encodingStyle' => "http://schemas.xmlsoap.org/soap/encoding/"
    } 

    def initialize merkav_transaction
      @savon = Savon.client(wsdl: WSDL_URL, namespaces:NAMESPACES, log: false, log_level: :error)
      @transaction = merkav_transaction
    end

    def run
      result = @transaction.generate_virtual_card
      raise StandardError, result[:status] if result[:status] != 'ok'

      self.generate_customer_data if @transaction.token.nil?
      raise StandardError, @transaction.status if @transaction.otpKey.nil?

      self.generate_transaction if @transaction.merkav_transaction_id.nil?
      raise StandardError, @transaction.status if @transaction.status != 'success'
    end

    def generate_customer_data
      card = @transaction.virtual_card

      params = { 
        'customer_firstname' => "test",
        'customer_lastname' => "test",
        'customer_email' => "test@test.com",
        'holder_firstname' => "test",
        'holder_lastname' => "test",
        'pan' => card.number,
        'digit' => card.cvv,
        'exp' => "#{card.exp_month}-#{card.exp_year}"
      } 

      response = @savon.call(:add_customer_data) do
        message('apiKey' => API_KEY, 'params' => Base64.strict_encode64(PHP.serialize(params)))
      end

      response_hash = {}
      response.hash[:envelope][:body][:add_customer_data_response][:result][:item].each do |data|
        response_hash[data[:key]] = data[:value]
      end

      if response_hash['status'] != 'OK'
        @transaction.status = "AddCustomerData failed"
      else
        @transaction.optkey = response_hash['otpKey']
        @transaction.token = response_hash['token']
      end
      @transaction.save
    end

    def generate_transaction
      params = {
        'paccount_id' => @transaction.vad_id,
        'type' => 'BILL',# REBILL,PREAUTH,ENCAISSEMENT_PREAUTH,REFUND
        'transaction_ip' => '127.0.0.1',# client IP
        'amount_cnts' => @transaction.amount,
        'client_reference' => 'test',# free reference
        'client_customer_id' => @transaction.id, # numeric reference
        'affiliate_id' => 1, # usefull for affiliation fraud
        'site_url' => 'http://www.test.com',
        'member_login' => 'test', # usefull for support
        'support_url' => 'http://www.test.com',
        'support_tel' => '+33 2 16 71 22 18',
        'support_email' => 'test@test.com',
        'customer_lang' => 'FR',
        'customer_useragent' => 'CVD TEST',
        'billing_invoicing_id' => 1, # your "id_facturation"
        'billing_description' => 'test',
        'billing_preauth_duration' => 0, # free period
        'billing_rebill_period' => 0, # rebill period in days
        'billing_rebill_duration' => 0, # 0 means unlimited rebill
        'billing_rebill_price_cnts' => 0, # rebill price
        'billing_initial_transaction_id' => 0 # used with ENCAISSEMENT_PREAUTH and REBILL and REFUND
      } 

      items = []

      params.each_pair do |k,v|
        items << {'key' => k, 'value' => v}
      end

      token = @transaction.token
      optkey = @transaction.optkey

      response = @savon.call(:transaction) do
        message(
          'apiKey' => API_KEY,
          'token' => token,
          'otpKey' => optkey,
          'params' => { 'item' => items },
          :attributes! => {
            'params' => { 'xsi:type' => "ns2:Map" },
            'token' => {'xsi:type' => 'xsd:string'},
            'otpKey' => {'xsi:type' => 'xsd:string'}
          }
        )
      end

      response_hash = {}
      response.hash[:envelope][:body][:transaction_response][:result][:item].each do |data|
        response_hash[data[:key]] = data[:value]
      end

      if response_hash['status'] != 'OK'
        @transaction.status = "CreateTransaction failed - #{response_hash['status_reason']}"
      else
        @transaction.status = 'success'
      end
      @transaction.merkav_transaction_id = response_hash["transaction_id"]
      @transaction.executed_at = Time.now
      @transaction.save
    end

    def self.set_quota amount
      Nest.new("merkav")[:quota].set(amount)
    end

    def self.get_quota
      Nest.new("merkav")[:quota].get.to_i
    end

    def self.add_quota amount
      self.set_quota(self.get_quota + amount)
    end
  end
end