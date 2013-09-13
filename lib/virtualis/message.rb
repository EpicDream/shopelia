module Virtualis
  class Message

    def initialize(operation, params, format=:xml)
      @template = File.read("#{Virtualis.configuration.messages_path}/#{operation}.#{format}.erb")
      @renderer = ERB.new(@template)

      params[:efs] = Virtualis.configuration.efs unless params.has_key?(:efs)
      params[:identifiant] = Virtualis.configuration.identifiant unless params.has_key?(:identifiant)
      params[:contrat] = Virtualis.configuration.contrat unless params.has_key?(:contrat)
      
      validate(params)
      @params = params
    end

    def validate(params)

      validators = {
        :efs         => /\A.{2}\Z/,
        :identifiant => /\A\d{8}\Z/,
        :contrat     => /\A.{10}\Z/,
        :reference   => /\A\d{19}\Z/,
        :montant     => /\A\d{1,15}\Z/,
        :devise      => /\A\d{3}\Z/,
        :duree       => /\A\d{1,2}\Z/,
        :type        => /\A.\Z/,
        :etat        => /\A\d\Z/
      }

      params.each_pair do |k, v|
        raise ArgumentError, "Unknown param #{k}" unless validators.has_key?(k)
        raise ArgumentError, "Invalid param #{k}: #{v}" unless validators[k].match(v)
      end

    end
  
    def to_xml
      @renderer.result(binding())
    end

  end

end
