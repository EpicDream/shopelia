class PhoneParser

  def self.is_mobile? number, country_iso
    if country_iso.downcase.eql?("fr")
      number =~ /^06/ || number =~ /^07/
    end
  end

end
