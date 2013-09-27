# -*- encoding : utf-8 -*-
class SuperInsoliteCom

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = "Non disponible" if version[:availability_text] =~ /^Stock,?$/i
    version
  end
end