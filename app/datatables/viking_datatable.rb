class VikingDatatable
  delegate :params, :h, :link_to, :time_ago_in_words, :truncate, :viking_failure_tags, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Product.where(viking_failure:true).where("updated_at > ?", 1.day.ago).count,
      iTotalDisplayRecords: products.total_entries,
      aaData: data
    }
  end

  private

  def data
    products.map do |product|
      [
        link_to(truncate(product.url, :length => 50), product.url),
        viking_failure_tags(product.product_versions.first),
        time_ago_in_words(product.updated_at)
      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    products = Product.where(viking_failure:true).where("updated_at > ?", 1.day.ago).order("#{sort_column} #{sort_direction}")
    products.page(page).per_page(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "asc" : "desc"
  end
end
