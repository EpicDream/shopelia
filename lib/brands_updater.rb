class BrandsUpdater
  ID_INDEX = 0
  BRAND_INDEX = 2
  
  def initialize(csv_path, col_sep="|")
    @csv_path = csv_path
    @col_sep = col_sep
  end
  
  def run
    CSV.foreach(@csv_path, col_sep:@col_sep) do |row|
      id, brand = row[ID_INDEX].strip, row[BRAND_INDEX].strip
      next if id.blank? || brand.blank?
      product = LookProduct.find(id)
      product.update_attributes(brand:brand)
    end
  end
  
end