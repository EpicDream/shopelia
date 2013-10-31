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
    'oe'    => 'œ'
  }

  def unaccent
    _str = self.dup
    UNACCENT_HASH.each do |k, v|
      _str.gsub!(/[#{v}]/, k)
    end
    _str
  end
  
end

