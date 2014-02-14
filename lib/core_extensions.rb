# -*- encoding : utf-8 -*-
class String

  def to_utf8
    self.force_encoding("UTF-8")
  rescue
    self
  end
    
  UNACCENT_HASH = {
    'A'   => 'ÀÁÂÃÄÅĀĂǍẠẢẤẦẨẪẬẮẰẲẴẶǺĄ',
    'a'   => 'àáâãäåāăǎạảấầẩẫậắằẳẵặǻą',
    'C'   => 'ÇĆĈĊČ',
    'c'   => 'çćĉċč',
    'D'   => 'ÐĎĐ',
    'd'   => 'ďđ',
    'E'   => 'ÈÉÊËĒĔĖĘĚẸẺẼẾỀỂỄỆ',
    'e'   => 'èéêëēĕėęěẹẻẽếềểễệ',
    'G'   => 'ĜĞĠĢ',
    'g'   => 'ĝğġģ',
    'H'   => 'ĤĦ',
    'h'   => 'ĥħ',
    'I'   => 'ÌÍÎÏĨĪĬĮİǏỈỊ',
    'i'   => 'ìíîï',
    'J'   => 'Ĵ',
    'j'   => 'ĵ',
    'K'   => 'Ķ',
    'k'   => 'ķ',
    'L'   => 'ĹĻĽĿŁ',
    'l'   => 'ĺļľŀł',
    'N'   => 'ÑŃŅŇ',
    'n'   => 'ñńņňŉ',
    'O'   => 'ÒÓÔÕÖØŌŎŐƠǑǾỌỎỐỒỔỖỘỚỜỞỠỢ',
    'o'   => 'òóôõöøōŏőơǒǿọỏốồổỗộớờởỡợð',
    'R'   => 'ŔŖŘ',
    'r'   => 'ŕŗř',
    'S'   => 'ŚŜŞŠ',
    's'   => 'śŝşš',
    'T'   => 'ŢŤŦ',
    't'   => 'ţťŧ',
    'U'   => 'ÙÚÛÜŨŪŬŮŰŲƯǓǕǗǙǛỤỦỨỪỬỮỰ',
    'u'   => 'ùúûüũūŭůűųưǔǖǘǚǜụủứừửữự',
    'W'   => 'ŴẀẂẄ',
    'w'   => 'ŵẁẃẅ',
    'Y'   => 'ÝŶŸỲỸỶỴ',
    'y'   => 'ýÿŷỹỵỷỳ',
    'Z'   => 'ŹŻŽ',
    'z'   => 'źżž',
    # Ligatures
    'AE'    => 'Æ',
    'ae'    => 'æ',
    'OE'    => 'Œ',
    'oe'    => 'œ',
    # Spaces
    ' '      => "\u00a0",

  }

  def unaccent
    _str = self.dup
    UNACCENT_HASH.each do |k, v|
      _str.gsub!(/[#{v}]/, k)
    end
    _str
  end
  
  def clean
    self.gsub(/\n|\r|\t/, ' ').strip
  rescue 
    @attempts ||= 0 and @attempts += 1
    encoded = encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    @attempts < 2 ? encoded.clean : encoded 
  end
  
end

class Date
  def self.parse_international(string)
    parse(month_to_english(string))
  end
 
  private
  
  def self.make_hash(names)
    names.inject({}) {|result, name| result[name] = MONTHNAMES[result.count+1] ; result }      
  end
 
  MONTH_TRANSLATIONS = {}    
  MONTH_TRANSLATIONS.merge! make_hash(%w/janvier fevrier mars avril mai juin juillet aout septembre octobre novembre decembre/) # French
  MONTH_TRANSLATIONS.merge! make_hash(%w/januar	februar	marz	april	mai	juni	juli	august	september	oktober	november	dezember/)  # German
  MONTH_TRANSLATIONS.merge! make_hash(%w/gennaio	febbraio	marzo	aprile	maggio	giugno	luglio	agosto	settembre	ottobre	novembre	dicembre/)  # Italian
  MONTH_TRANSLATIONS.merge! make_hash(%w/enero	febrero	marzo	abril	mayo	junio	julio	agosto	septiembre	octubre	noviembre	diciembre/) # Spanish
 
  def self.month_to_english(string)
    month_from = string[/[^\s\d,]+/i]
    if month_from
      month_to = MONTH_TRANSLATIONS[month_from.downcase.unaccent]
      return string.sub(month_from, month_to.to_s) if month_to
    end
    return string
  end
end

module YAML
  def self.load_relative_file(path)
    caller_path = caller.first.match(/(.*)\/.*?:/).captures.first
    path = caller_path + "/" + path
    YAML.load_file(path)
  end
end

class ActiveRecord::Base
  def self.json_attributes attributes
    attributes.each do |attribute|
      define_method(attribute) { JSON.parse(read_attribute(attribute))}
    end
  end
end

class URI::Generic
  def base_url
    "#{self.scheme}://#{self.host}"
  end
end