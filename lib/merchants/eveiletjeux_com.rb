class EveiletjeuxCom

  def initialize url
    @url = url
  end

  def monetize
    "http://ad.zanox.com/ppc/?25424162C654654636&ulp=[[http://logc57.xiti.com/gopc.url?xts=425426&xtor=AL-146-1%5Btypologie%5D-REMPLACE-%5Bparam%5D&xtloc=#{@url}&url=http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm]]"
  end

  def canonize
    @url
  end
end