module Virtualis
  class Card

    def self.create(params, format=:xml)
      params[:devise] = '978' unless params.has_key?(:devise)
      params[:type] = 'U'     unless params.has_key?(:type)
      params[:duree] = '1'    unless params.has_key?(:duree)
      begin
        raise ArgumentError, "Missing montant" unless params.has_key?(:montant)
        message = Virtualis::Message.new(:creation_carte_virtuelle, params, format)
        result = Virtualis::Request.new.send(message.to_xml)     
        bean = Virtualis::Bean.new(:creation_carte_virtuelle, result)
      rescue ArgumentError => e
        hash = {
          'error_str' => e.to_s,
          'status' => 'error'
        }
        return hash
      end
      return bean.to_hash
    end

    def self.detail(params, format=:xml)
      begin
        raise ArgumentError, "Missing card reference" unless params.has_key?(:reference)
        message = Virtualis::Message.new(:detail_carte_virtuelle, params, format)
        result = Virtualis::Request.new.send(message.to_xml)
        bean = Virtualis::Bean.new(:detail_carte_virtuelle, result)
      rescue ArgumentError => e
        hash = {
          'error_str' => e.to_s,
          'status' => 'error'
        }
        return hash
      end
      return bean.to_hash
    end

    def self.cancel(params, format=:xml)
      params[:etat] = '1' unless params.has_key?(:etat)
      begin
        raise ArgumentError, "Missing card reference" unless params.has_key?(:reference)
        message = Virtualis::Message.new(:annulation_carte_virtuelle, params, format)
        result = Virtualis::Request.new.send(message.to_xml)
        bean = Virtualis::Bean.new(:annulation_carte_virtuelle, result)
      rescue ArgumentError => e
        hash = {
          'error_str' => e.to_s,
          'status' => 'error'
        }
        return hash
      end
      return bean.to_hash
    end

  end


end
