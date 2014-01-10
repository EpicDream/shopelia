module Paperclip
  class TempfileFactory
    def basename_with_hashed
      name = basename_without_hashed
      Digest::SHA1.hexdigest name
    end
    alias_method_chain :basename, :hashed
  end
end
