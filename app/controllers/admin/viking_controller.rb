class Admin::VikingController < Admin::AdminController

  def index
    result = Product.where("updated_at > ?", 1.day.ago).group(:viking_failure).count
    @total = result[false].to_i + result[true].to_i
    @performance = @total > 0 ? result[false].to_f * 100 / (result[false].to_f + result[true].to_f) : 0
    
    merchants = {}
    Product.where("products.updated_at > ?", 1.day.ago).joins(:merchant).group("merchants.name,products.viking_failure").select("count(*) as count,merchants.name,products.viking_failure").each do |s|
      merchants[s.name] ||= {}
      merchants[s.name][s.viking_failure] = s.count.to_f
    end
    
    stats = []
    merchants.each do |m|
      hash = {}
      hash[:name] = m[0]
      hash[:total] = m[1][false].to_f + m[1][true].to_f
      hash[:rate] = hash[:total] > 0 ? m[1][false].to_f*100 / hash[:total] : 0
      stats << hash if hash[:total] >= 5
    end
    
    @merchant_stats = stats.sort_by { |k| -k[:total] }
    
    respond_to do |format|
      format.html
      format.json { render json: VikingDatatable.new(view_context) }
    end
  end

end
