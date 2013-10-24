# -*- encoding : utf-8 -*-
require 'test_helper'

class ZanoxComTest < ActiveSupport::TestCase

  test "it should canonize" do
    urls = [
      { in: 'http://ad.zanox.com/ppc/?22189354C1364358154&amp;ULP=[[00000318&amp;eseg-name=id_affilie&amp;eseg-item=ID_AFFILIE&amp;eurl=http%3A%2F%2Fonline.carrefour.fr%2Felectromenager-multimedia%2Fhp%2Fcartouche-encre-n-342-couleur_a00000318_frfr.html%23srcid%3D11068%3Fxtor%3DAL-3-%5BProgramme_Standard%5D-%5BID_AFFILIE%5D-%5BFlux_Produit%5D-%5B00000318%5D%26LGWCODE%3D00000318%3B23678%3B13]]',
        out: 'http://online.carrefour.fr/electromenager-multimedia/hp/cartouche-encre-n-342-couleur_a00000318_frfr.html'
      },
      { in: 'http://ad.zanox.com/ppc/?19436028C1562252816&amp;ULP=[[http://www.darty.com/nav/achat/petit_electromenager/cuisson_quotidienne/accessoire_autocuiseur/seb_joint_o_clip_10l_x1.html?dartycid=aff_zxpublisherid_comp_0005410]]',
        out: 'http://www.darty.com/nav/achat/petit_electromenager/cuisson_quotidienne/accessoire_autocuiseur/seb_joint_o_clip_10l_x1.html'
      },
      { in: 'http://ad.zanox.com/ppc/?18920697C1372641144&amp;ULP=[[http://www.toysrus.fr/redirect_znx.jsp?url=http%3A%2F%2Fwww.toysrus.fr%2Fproduct%2Findex.jsp%3FproductId%3D10002181]]',
        out: 'http://www.toysrus.fr/product/index.jsp?productId=10002181'
      },
      { in: 'http://ad.zanox.com/ppc/?19054231C2048768278&amp;ULP=[[livre.fnac.com/a1000033/John-Grisham-The-firm]]',
        out: 'http://livre.fnac.com/a1000033/John-Grisham-The-firm'
      },
      { in: 'http://ad.zanox.com/ppc/?19089773C1754659089&amp;ULP=[[http://www.imenager.com/accessoire-cuisson/fp-336342-seb?site=zanox&amp;utm_source=Zanox&amp;utm_medium=Affiliation&amp;utm_campaign=ZanoxIM]]',
        out: 'http://www.imenager.com/accessoire-cuisson/fp-336342-seb'
      },
      { in: 'http://ad.zanox.com/ppc/?19472705C2093117078&amp;ULP=[[474-20606-100171/]]',
        out: 'http://ad.zanox.com/ppc/?19472705C2093117078&amp;ULP=[[474-20606-100171/]]'
      },
      { in: 'http://ad.zanox.com/ppc/?19436175C242487251&amp;ULP=[[m/ps/mpid:MP-0002CM2247254%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d]]',
        out: 'http://ad.zanox.com/ppc/?19436175C242487251&amp;ULP=[[m/ps/mpid:MP-0002CM2247254%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d]]'
      },
      { in: 'http://ad.zanox.com/ppc/?19024603C1357169475&amp;ULP=[[http://logc57.xiti.com/gopc.url?xts=425426&amp;xtor=AL-146-%5Btypologie%5D-%5BREMPLACE%5D-%5Bflux%5D&amp;xtloc=http://www.eveiletjeux.com/mallette-visseuse-technico/produit/0006216&amp;url=http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm]]',
        out: 'http://www.eveiletjeux.com/mallette-visseuse-technico/produit/0006216'
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], ZanoxCom.new(url[:in]).canonize)
    end
  end
end

