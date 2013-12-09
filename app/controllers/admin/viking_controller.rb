class Admin::VikingController < Admin::AdminController

  def index
    result = Product.where("updated_at > ?", 1.day.ago).group(:viking_failure).count
    @total = result[false].to_i + result[true].to_i
    @performance = @total > 0 ? result[false].to_f * 100 / (result[false].to_f + result[true].to_f) : 0
    
    merchants = {}
    Product.where("products.updated_at > ?", 1.year.ago).joins(:merchant).group("merchants.name,products.viking_failure").select("count(*) as count,merchants.name,merchants.mapping_id,products.viking_failure").each do |s|
      merchants[s.name] ||= {}
      merchants[s.name][s.viking_failure] = s.count.to_f
      merchants[s.name][:viking_support] = s.mapping_id.present?
    end
    
    stats = []
    merchants.each do |name, m|
      hash = {}
      hash[:viking_support] = m[:viking_support]
      hash[:name] = name
      hash[:total] = m[false].to_f + m[true].to_f
      hash[:rate] = hash[:total] > 0 ? m[false].to_f*100 / hash[:total] : 0
      stats << hash if hash[:total] > 10
    end
    
    @merchant_stats = stats.sort_by { |k| -k[:total] }
    
    respond_to do |format|
      format.html
      format.json { render json: VikingDatatable.new(view_context) }
    end
  end

end
