# -*- encoding : utf-8 -*-

module AlgoliaFeed

  class CommissionJunctionFiler < Filer

    def initialize(params={})
      super

      self.urls = params[:urls] || [
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/Gas_Bijoux_FR-Catalogue_GasBijoux.xml.gz',
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/LUISAVIAROMA_Affiliate_Program-Catalog_NOL.xml.gz',
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/LUISAVIAROMA_Affiliate_Program-Complete_Catalog.xml.gz',
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/LUISAVIAROMA_Affiliate_Program-New_Season.xml.gz',
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/LUISAVIAROMA_Affiliate_Program-Product_Catalog.xml.gz',
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/Little_Fashion_Gallery_FR-Catalogue_LFG.xml.gz',
        'ftp://4081374:c~gVVmhZ@datatransfer.cj.com/outgoing/productcatalog/145189/Montaigne_Market-Catalogue_Montaigne_Market.xml.gz'
      ]

      self.parser_class = params[:parser_class] || 'AlgoliaFeed::CommissionJunction'
    end

  end

  class CommissionJunction < XmlParser

    def initialize(params={})
      super

      self.conversions = params[:conversions] || {
        'name'                 => 'name',
        'price'                => 'price',
        'saleprice'            => 'saleprice',
        'buyurl'               => 'product_url',
        'description'          => 'description',
        'imageurl'             => 'image_url',
        'currency'             => 'currency',
        'instock'              => 'availability',
        'manufacturer'         => 'brand',
        'standardshippingcost' => 'price_shipping',
      }

      self.category_fields = ['advertisercategory', 'thirdpartycategory']

      params[:parser_class] = self.class
      self.filer = CommissionJunctionFiler.new(params)
      self
    end

    def canonize(url)
      if m = url.match(/url=(.+)\Z/)
        matched_url = URI.decode(m[1])
        if matched_url =~ /lengow/
          return Linker.clean(matched_url)
        else
          return matched_url
        end
      else
        return Linker.clean(url)
      end
    end

    def process_product(product)
      record = super

      record['price'] = record['saleprice'] if record.has_key?('saleprice')

      record['price'] = to_cents(record['price'])
      record['price_shipping'] = to_cents(record['price_shipping'])

      record
    end

  end
end

