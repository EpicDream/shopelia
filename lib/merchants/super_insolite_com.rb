# -*- encoding : utf-8 -*-
class SuperInsoliteCom

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = "Non disponible" if version[:availability_text] =~ /^Stock,?$/i
    version
  end

  def process_name version
    version[:name] = $~[1] if version[:name] =~ /^(.*)\s+\d+,\d+ €$/
    version
  end
end