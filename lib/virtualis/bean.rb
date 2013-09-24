module Virtualis 
  class Bean #Classe à compléter/revoir suivant les réponses pour d'autres services
    VIRTUAL_CARD_BEAN_TAG = "CarteVirtuelleBean"
    
    def initialize operation, message
      @operation = operation.to_s
      @document = Nokogiri::XML(message, &:noblanks)
      @envelope = @document.xpath("//soap:Envelope")
    end
    
    def to_hash
      hash = Hash.from_xml(@envelope.to_xml)
      hash = hash["Envelope"]["Body"][response_tag][VIRTUAL_CARD_BEAN_TAG]
      hash['number'] = hash['numeroCarte'].gsub(/000\s*\Z/, '') if hash.has_key?('numeroCarte') and hash['numeroCarte'].present?
      if hash.has_key?('dateFinValiditeCV') and hash['dateFinValiditeCV'].present?
        if m = /\A(\d{4})(\d{2})\d{2}/.match(hash['dateFinValiditeCV'])
          hash['exp_year'] = m[1]
          hash['exp_month'] = m[2]
        end
      end
      hash['cvv'] = hash['valeurCarteCrypto'] if hash.has_key?('valeurCarteCrypto') and hash['valeurCarteCrypto'].present?
      hash['error_str'] = hash['libelleResultat'] if hash.has_key?('libelleResultat') and hash['libelleResultat'].present?
      hash['status'] = hash['resultat'] == '0' ? 'ok' : 'error'
      return hash
    end
    
    private
    
    def response_tag
      "#{@operation.camelize(:lower)}Response"
    end
    
  end
end
