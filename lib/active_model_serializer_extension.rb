module ActiveModelSerializerExtension
  module JsonWithoutNilKeys
        
    def serializable_hash
      super.reject { |k, v| v.nil? }
    end
  end
end