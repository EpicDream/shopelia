class DartyCom

  def initialize url
    @url = url
  end

  def monetize
    "http://ad.zanox.com/ppc/?25424898C784334680&ulp=[[#{@url.gsub("http://", "")}?dartycid=aff_zxpublisherid_lien-profond-libre_lientexte]]"
  end

end