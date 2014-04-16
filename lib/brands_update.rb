class BrandsUpdate

  def initialize(csv_path)
    @csv_path = csv_path
  end
  
  def run
    CSV.foreach(@csv_path, col_sep:'|') do |row|
      next if row[0].blank?
      brand = row[2].strip
      next if brand.blank?
      product = LookProduct.find(row[0])
      product.brand = brand
      product.save!
    end
  end
  
  
end